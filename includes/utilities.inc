<?php

/**
 * @file
 * Helper functions used by this module.
 */

/**
 * Run an XSLT, and return the results.
 *
 * @param array $info
 *   An associative array of parameters, containing:
 *   - input: The input XML in a string.
 *   - xsl: The path to an XSLT file.
 *
 * @return string
 *   The transformed XML, as a string.
 */
function islandora_premis_run_xsl_transform($info) {
  $xsl = new DOMDocument();
  $xsl->load($info['xsl']);
  $input = new DOMDocument();
  $input->loadXML($info['input']);
  $processor = new XSLTProcessor();
  $processor->importStylesheet($xsl);
  // These parameters are used in foxml_to_premis.xsl.
  $processor->setParameter('', 'premis_agent_name_organization', variable_get('islandora_premis_agent_name', 'Your Organization'));
  $processor->setParameter('', 'premis_agent_identifier_organization', variable_get('islandora_premis_agent_identifier', 'some_unique_string'));
  $processor->setParameter('', 'premis_agent_identifier_type', variable_get('islandora_premis_agent_identifier_type', 'MARC Organization Codes'));
  $processor->setParameter('', 'premis_agent_type_organization', variable_get('islandora_premis_agent_type', 'organization'));
  $processor->setParameter('', 'fedora_commons_version', islandora_premis_get_fc_version());
  // @ suppresses warnings regarding unregistered prefixes.
  return @$processor->transformToXML($input);
}

/**
 * Grabs FOXML the given object, and returns it transformed to PREMIS.
 *
 * @param AbstractObject $object
 *   A Fedora object containing a FOXML datastream.
 *
 * @return array|bool 
 *   An array containing the serialized FOXML and the path to the stylesheet,
 *   or FALSE if the FOXML is not retrievable.
 */
function islandora_premis_transform_foxml_to_premis(AbstractObject $object) {
  $foxml_str = islandora_premis_get_foxml($object);
  if (!$foxml_str) {
    drupal_not_found();
  }

  // Acrobatics to insert the FITS TECHMD datastream into the outgoing
  // FOXML. We can't use the DOM to do this because PHP is not able to
  // pass elements into an XSL stylesheet if they contains both double
  // and single quotes (bug reference https://bugs.php.net/bug.php?id=64137).
  // To get around this, we use XMLWriter to create an inline datastream
  // (ID="FITS_OUTPUT_COPY") and insert that as serialized XML into the FOXML
  // via XMLWriter's writeRaw() function so we can process it in
  // foxml_to_premis.xsl.
  if ($foxml_str) {
    $dsid = variable_get('islandora_fits_techmd_dsid', 'TECHMD');
    if (isset($object[$dsid])) {
      $ds = new XMLWriter();
      $ds->openMemory();
      $ds->setIndent(TRUE);
      $ds->startDocument();
      $ds->startElementNS('foxml', 'datastream', 'info:fedora/fedora-system:def/foxml#');
      $ds->writeAttribute('xmlns:xsi', "http://www.w3.org/2001/XMLSchema-instance");
      // We don't use the DSID configured in the FITS module because we need to
      // be able to predict it in the XMLT.
      $ds->writeAttribute('ID', 'FITS_OUTPUT_COPY');
      $ds->writeAttribute('STATE', 'A');
      $ds->writeAttribute('CONTROL_GROUP', 'X');
      $ds->writeAttribute('VERSIONABLE', 'false');
      $ds->startElementNS('foxml', 'datastreamVersion', NULL);
      $ds->writeAttribute('ID', 'FITS_OUTPUT_COPY.0');
      $ds->writeAttribute('LABEL', 'Copy of FITS XML');
      $ds->writeAttribute('MIMETYPE', 'text/xml');
      $ds->startElementNS('foxml', 'xmlContent', NULL);
      $fits_string = preg_replace('/^<\?xml\sversion="1\.0"\sencoding="UTF-8"\?>/',
        '', $object[$dsid]->content);
      $ds->writeRaw($fits_string);
      // Closes foxml:xmlContent.
      $ds->endElement();
      // Closes foxml:datastreamVersion.
      $ds->endElement();
      // Closes foxml:datastream.
      $ds->endElement();
      $ds->endDocument();
      $ds_string = $ds->outputMemory();
      // Inline XML can't have an XML declaration.
      $ds_string = preg_replace('/^<\?xml\sversion="1\.0"\?>/', '', $ds_string);
      $foxml = new DOMDocument();
      $foxml->loadXML($foxml_str);
      $fragment = $foxml->createDocumentFragment();
      $fragment->appendXML($ds_string);
      $foxml->documentElement->appendChild($fragment);
      $foxml_str = $foxml->saveXML();
    }
  }

  return islandora_premis_run_xsl_transform(array(
    'input' => $foxml_str,
    'xsl' => drupal_get_path('module', 'islandora_premis') . '/xml/foxml_to_premis.xsl',
  ));
}

/**
 * Produce HTML representing PREMIS content.
 *
 * @param AbstractObject $object
 *   A Fedora object containing a MODS datastream.
 *
 * @return string
 *   The transformed HTML, as a string.
 */
function islandora_premis_transform_premis_to_html(AbstractObject $object) {
  return islandora_premis_run_xsl_transform(array(
    'input' => islandora_premis_transform_foxml_to_premis($object),
    'xsl' => drupal_get_path('module', 'islandora_premis') . '/xml/premis_to_html.xsl',
  ));
}


/**
 * Renders the PREMIS tab.
 *
 * @pararm AbstractObject $object
 *   The object the PREMIS belongs to.
 *
 * @return array
 *   A renderable array representing the tab.
 */
function islandora_premis_view(AbstractObject $object) {
  $tab = array();
  if (user_access('download premis metadata')) {
    $tab['link'] = array('#markup' => l(t('Download PREMIS'), "islandora/object/{$object->id}/download_premis"));
  }
  if (user_access('view premis metadata')) {
    $tab['premis'] = array('#markup' => islandora_premis_transform_premis_to_html($object));
  }
  return $tab;
}

/**
 * Gets FOXML via tuque.
 *
 * @pararm AbstractObject $object
 *   The object the FOXML belongs to
 *
 * @return string|bool
 *   The FOXML, or FALSE if the FOXML is not available.
 */
function islandora_premis_get_foxml(AbstractObject $object) {
  $foxml = '';
  // Use the Tuque API-M to export the FOXML for the object.
  global $user;
  $fedora_url = variable_get('islandora_base_url', 'http://localhost:8080/fedora');
  try {
    $connection = islandora_get_tuque_connection($user, $fedora_url);
    $foxml = $connection->api->m->export($object->id,
      array(
        'format' => 'info:fedora/fedora-system:FOXML-1.1',
        'context' => 'migrate',
        'encoding' => 'UTF-8')
      );
  }
  catch (exception $e) {
    drupal_set_message(t(
        "Error retrieving FOXML required to generate PREMIS: '@message'",
        array("@message" => $e->getMessage())));
    watchdog(
      'islandora_premis',
      'Error retrieving FOXML required to generate PREMIS, with stack: @trace',
      array('@trace' => $e->getTraceAsString()),
      WATCHDOG_ERROR
    );
  }

  if ($foxml) {
    return $foxml;
  }
  else {
    return FALSE;
  }
}

/**
 * Performs call to Fedora REST API to get version number.
 *
 * @return string
 *   A string representing the Fedora Commons version
 */
function islandora_premis_get_fc_version() {
  $url = variable_get('islandora_base_url', 'http://localhost:8080/fedora') .
    '/describe?xml=true';
  $describe_xml = file_get_contents($url);
  $fedora_repository = new SimpleXMLElement($describe_xml);
  return $fedora_repository->repositoryVersion;
}
