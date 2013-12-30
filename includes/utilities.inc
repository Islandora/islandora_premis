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
 *   A Fedora object containing a MODS datastream.
 *
 * @return string
 *   The transformed XML, as a string.
 */
function islandora_premis_transform_foxml_to_premis(AbstractObject $object) {
  if (!isset($object['FOXML'])) {
    drupal_not_found();
  }
  $mods_str = trim($object['FOXML']->content);
  return islandora_premis_run_xsl_transform(array(
    'input' => $mods_str,
    'xsl' => drupal_get_path('module', 'islandora_premis') . '/xml/foxml-to-premis.xsl',
  ));
}

/**
 * Produce HTML representing PREMIS content.
 *
 * First, transforms MODS to PREMIS, and then PREMIS to HTML.
 *
 * @param AbstractObject $object
 *   A Fedora object containing a MODS datastream.
 *
 * @return string
 *   The transformed HTML, as a string.
 */
function islandora_premis_to_html(AbstractObject $object) {
  return islandora_premis_run_xsl_transform(array(
    'input' => islandora_marcxml_transform_foxml_to_premis($object),
    'xsl' => drupal_get_path('module', 'islandora_premis') . '/xml/foxml-premis.xsl',
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
