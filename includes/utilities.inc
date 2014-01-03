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
  // XXX: Suppressing warnings regarding unregistered prefixes.
  return @$processor->transformToXML($input);
}

/**
 * Grabs FOXML the given object, and returns it transformed to PREMIS.
 *
 * @param AbstractObject $object
 *   A Fedora object containing a FOXML datastream.
 *
 * @return string
 *   The transformed XML, as a string.
 */
function islandora_premis_transform_foxml_to_premis(AbstractObject $object) {
  $foxml_str = islandora_premis_get_foxml($object);
  if (!$foxml_str) {
    drupal_not_found();
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
    'xsl' => drupal_get_path('module', 'islandora_premis') . '/xml/foxml_to_premis.xsl',
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
  return array(
    'link' => array(
      '#markup' => l(t('Download PREMIS'), "islandora/object/{$object->id}/download_premis"),
    ),
    'premis' => array(
      '#markup' => islandora_premis_transform_premis_to_html($object),
    ),
  );
}

function islandora_premis_get_foxml(AbstractObject $object) {
  // Use the Tuque API-M to export the FOXML for the object.
  global $user;
  $fedora_url = variable_get('islandora_base_url', 'http://localhost:8080/fedora');
  $connection = islandora_get_tuque_connection($user, $fedora_url);
  $foxml = $connection->api->m->export($object->id,
    array('format' => 'info:fedora/fedora-system:FOXML-1.1',
      'context' => 'archive',
      'encoding' => 'UTF-8')
    );

  if ($foxml) {
    return $foxml;
  }
  else {
    return FALSE;
  }
}
