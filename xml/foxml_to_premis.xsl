<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:foxml="info:fedora/fedora-system:def/foxml#" xmlns:audit="info:fedora/fedora-system:def/audit#" xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#" xmlns:islandora="http://islandora.ca/ontology/relsext#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:fits="http://hul.harvard.edu/ois/xml/ns/fits/fits_output" version="1.0" exclude-result-prefixes="fedora fedora-model foxml audit islandora rdf">
  <xsl:output method="xml" encoding="utf-8" indent="yes"/>
  <!-- Define a global parameter containing the Islandora object's PID. -->
  <xsl:param name="pid" select="foxml:digitalObject/@PID"/>
  <!-- Global parameters exported from the XSLT processor. -->
  <xsl:param name="premis_agent_name_organization"/>
  <xsl:param name="premis_agent_identifier_organization"/>
  <xsl:param name="premis_agent_identifier_type"/>
  <xsl:param name="premis_agent_type_organization"/>
  <!-- Note: the version number is current at time of deriving PREMIS, not at time of creation of audit log entry. -->
  <xsl:param name="fedora_commons_version"/>
  <xsl:preserve-space elements="*"/>
  <xsl:template match="foxml:digitalObject">
    <premis xmlns="info:lc/xmlns/premis-v2" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xsi:schemaLocation="info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/v2/premis.xsd" version="2.2">
      <xsl:comment>PREMIS data for Islandora object <xsl:value-of select="$pid"/>. Contains object entries for each datastream
        in an Islandora object, and event entries documenting all fixity checks performed on
        versions of those datastreams. Note that a datastream version that has never had a fixity
        check performed on it will not be linked to any fixity check events.</xsl:comment>
      <!-- Objects first. -->
      <xsl:comment>'Internal' eventIdentifierType values are comprised of Fedora datasteam ID plus ':' plus Fedora Audit Record ID.</xsl:comment>
      <xsl:for-each select="foxml:datastream[not(@ID='FITS_OUTPUT_COPY')]">
        <xsl:for-each select="foxml:datastreamVersion">
          <xsl:variable name="datastream_id" select="@ID"/>
          <object xsi:type="file">
            <objectIdentifier>
              <objectIdentifierType>Fedora Commons datastreamVersion ID</objectIdentifierType>
              <objectIdentifierValue>
                <xsl:value-of select="@ID"/>
              </objectIdentifierValue>
            </objectIdentifier>
            <objectCharacteristics>
              <compositionLevel>0</compositionLevel>
              <fixity>
                <messageDigestAlgorithm>
                  <xsl:value-of select="foxml:contentDigest/@TYPE"/>
                </messageDigestAlgorithm>
                <messageDigest>
                  <xsl:value-of select="foxml:contentDigest/@DIGEST"/>
                </messageDigest>
              </fixity>
              <xsl:if test="string-length(@SIZE)">
                <size>
                  <xsl:value-of select="@SIZE"/>
                </size>
              </xsl:if>
              <format>
                <formatDesignation>
                  <formatName>
                    <xsl:value-of select="@MIMETYPE"/>
                  </formatName>
                </formatDesignation>
              </format>
              <!-- We only want to output the FITS XML if we are dealing with the OBJ datastream. -->
              <xsl:if test="../@ID='OBJ'">
                <xsl:if test="/foxml:digitalObject/foxml:datastream[@ID='FITS_OUTPUT_COPY']">
                  <objectCharacteristicsExtension>
                    <xsl:copy-of select="/foxml:digitalObject/foxml:datastream[@ID='FITS_OUTPUT_COPY']/foxml:datastreamVersion[@ID='FITS_OUTPUT_COPY.0']/foxml:xmlContent/fits:fits"/>
                  </objectCharacteristicsExtension>
                </xsl:if>
              </xsl:if>
            </objectCharacteristics>
            <storage>
              <contentLocation>
                <contentLocationType>Fedora Commons contentLocation REF value</contentLocationType>
                <contentLocationValue>
                  <xsl:value-of select="foxml:contentLocation/@REF"/>
                </contentLocationValue>
              </contentLocation>
            </storage>
            <!-- There should only be one audit:auditTrail but this for-each loop accounts for multiple. -->
            <xsl:for-each select="/foxml:digitalObject/foxml:datastream[@ID='AUDIT']/foxml:datastreamVersion/foxml:xmlContent/audit:auditTrail">
              <xsl:for-each select="audit:record">
                <!-- We're only interested in audit:records that document a PREMIS fixityEvent. -->
                <xsl:if test="contains(audit:justification, concat('PREMIS:file=', foxml:contentLocation/@REF))">
                  <xsl:variable name="responsibility" select="audit:responsibility"/>
                  <xsl:variable name="date" select="audit:date"/>
                  <xsl:variable name="justification" select="audit:justification"/>
                  <linkingEventIdentifier>
                    <linkingEventIdentifierType>Internal</linkingEventIdentifierType>
                    <linkingEventIdentifierValue>
                      <xsl:value-of select="concat($datastream_id, ':', @ID)"/>
                    </linkingEventIdentifierValue>
                  </linkingEventIdentifier>
                </xsl:if>
              </xsl:for-each>
            </xsl:for-each>
          </object>
        </xsl:for-each>
      </xsl:for-each>
      <!-- Then their events. -->
      <xsl:comment>'Internal' eventIdentifierType values are comprised of Fedora datasteam ID plus ':' plus Fedora Audit Record ID.</xsl:comment>
      <xsl:for-each select="foxml:datastream[not(@ID='FITS_OUTPUT_COPY')]">
        <xsl:for-each select="foxml:datastreamVersion">
          <xsl:variable name="event_content_location" select="foxml:contentLocation/@REF"/>
          <xsl:variable name="datastream_id" select="@ID"/>
          <!-- There should only be one audit:auditTrail but this for-each loop accounts for multiple. -->
          <xsl:for-each select="/foxml:digitalObject/foxml:datastream[@ID='AUDIT']/foxml:datastreamVersion/foxml:xmlContent/audit:auditTrail">
            <xsl:for-each select="audit:record">
              <!-- We're only interested in audit:records that document a PREMIS fixityEvent. -->
              <xsl:if test="contains(audit:justification, concat('PREMIS:file=', $event_content_location))">
                <xsl:variable name="responsibility" select="audit:responsibility"/>
                <xsl:variable name="date" select="audit:date"/>
                <xsl:variable name="justification" select="audit:justification"/>
                <event>
                  <eventIdentifier>
                    <eventIdentifierType>Internal</eventIdentifierType>
                    <eventIdentifierValue>
                      <xsl:value-of select="concat($datastream_id, ':', @ID)"/>
                    </eventIdentifierValue>
                  </eventIdentifier>
                  <eventType>fixity check</eventType>
                  <eventDateTime>
                    <xsl:value-of select="$date"/>
                  </eventDateTime>
                  <eventOutcomeInformation>
                    <eventOutcome>
                      <!-- eventOutcome should be coded, not free text. -->
                      <xsl:value-of select="substring-after(audit:justification, 'PREMIS:eventOutcome=')"/>
                    </eventOutcome>
                  </eventOutcomeInformation>
                  <linkingAgentIdentifier>
                    <linkingAgentIdentifierType>
                      <xsl:value-of select="$premis_agent_identifier_type"/>
                    </linkingAgentIdentifierType>
                    <linkingAgentIdentifierValue>
                      <xsl:value-of select="$premis_agent_identifier_organization"/>
                    </linkingAgentIdentifierValue>
                    <linkingAgentRole>Implementer</linkingAgentRole>
                  </linkingAgentIdentifier>
                  <linkingAgentIdentifier>
                    <linkingAgentIdentifierType>URI</linkingAgentIdentifierType>
                    <linkingAgentIdentifierValue>http://www.fedora-commons.org/</linkingAgentIdentifierValue>
                    <linkingAgentRole>Validator</linkingAgentRole>
                  </linkingAgentIdentifier>
                </event>
              </xsl:if>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:for-each>
      <!-- Then agents. -->
      <agent>
        <agentIdentifier>
          <agentIdentifierType>
            <xsl:value-of select="$premis_agent_identifier_type"/>
          </agentIdentifierType>
          <agentIdentifierValue>
            <xsl:value-of select="$premis_agent_identifier_organization"/>
          </agentIdentifierValue>
        </agentIdentifier>
        <agentName>
          <xsl:value-of select="$premis_agent_name_organization"/>
        </agentName>
        <agentType>
          <xsl:value-of select="$premis_agent_type_organization"/>
        </agentType>
      </agent>
      <agent>
        <agentIdentifier>
          <agentIdentifierType>URI</agentIdentifierType>
          <agentIdentifierValue>http://www.fedora-commons.org/</agentIdentifierValue>
        </agentIdentifier>
        <agentName>Fedora Repository <xsl:value-of select="$fedora_commons_version"/></agentName>
        <agentType>software</agentType>
      </agent>
      <!-- rights metadata -->
      <rights>
        <rightsExtension>
          <dc:rights>
            <xsl:value-of select="/foxml:digitalObject/foxml:datastream/foxml:datastreamVersion[last()]/foxml:xmlContent/oai_dc:dc/dc:rights"/>
          </dc:rights>
        </rightsExtension>
      </rights>
    </premis>
  </xsl:template>
</xsl:stylesheet>
