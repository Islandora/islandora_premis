<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:foxml="info:fedora/fedora-system:def/foxml#" xmlns:audit="info:fedora/fedora-system:def/audit#"
    xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#"
    xmlns:islandora="http://islandora.ca/ontology/relsext#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    exclude-result-prefixes="fedora fedora-model foxml audit islandora rdf">

    <xsl:output method="xml" encoding="utf-8" indent="yes"/>

    <!-- Define a global parameter containing the Islandora object's PID. -->
    <xsl:param name = "pid" select="foxml:digitalObject/@PID" />

    <!-- Global parameters exported from the XSLT processor. -->
    <xsl:param name="premis_agent_name_organization" />
    <xsl:param name="premis_agent_identifier_organization" />
    <xsl:param name="premis_agent_identifier_type" />
    <xsl:param name="premis_agent_type_organization" />
    
    <!-- parameters for rights -->
    <xsl:param name="premis_rights_statuteInformation_statuteJurisdiction"/>
    <xsl:param name="premis_rights_copyrightInformation_copyrightStatus_copyrightJurisdiction"/>
    
    <!-- Note: the version number is current at time of deriving PREMIS, not at time of creation of audit log entry. -->
    <xsl:param name="fedora_commons_version" />

    <xsl:preserve-space elements="*" />

    <xsl:template match="foxml:digitalObject">
        <premis xmlns="info:lc/xmlns/premis-v2" xsi:schemaLocation="info:lc/xmlns/premis-v2
            http://www.loc.gov/standards/premis/v2/premis.xsd" version="2.2"
            xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/">
        
        <xsl:comment>PREMIS data for Islandora object <xsl:value-of select="$pid" />. Contains object entries for each Managed datastream
        in an Islandora object, and event entries documenting all fixity checks performed on versions of those datastreams.
        Note that a datastream version that has never had a fixity check performed on it will not be linked to any fixity
        check events.</xsl:comment>

        <!-- Objects first. --> 
        
        <xsl:comment>'Internal' eventIdentifierType values are comprised of Fedora datasteam ID plus ':' plus Fedora Audit Record ID.</xsl:comment>

        <!-- Currently, we only describe 'managed' datastreams. -->
        <xsl:for-each select="foxml:datastream[@CONTROL_GROUP='M']">
            <xsl:for-each select="foxml:datastreamVersion">
                <xsl:variable name="content_location" select="foxml:contentLocation/@REF" />
                <xsl:variable name="datastream_id" select="@ID" />
                <object xsi:type="file">
                    <objectIdentifier>
                        <objectIdentifierType>Fedora Commons datastreamVersion ID</objectIdentifierType>
                        <objectIdentifierValue><xsl:value-of select="@ID"/></objectIdentifierValue>
                    </objectIdentifier>
                    <objectCharacteristics>
                        <!-- Test for original content (compositionLevel = 0) and derived content (compositionLevel = 1). -->
                        <xsl:choose>
                            <xsl:when test="starts-with(@ID, 'OBJ') or starts-with(@ID, 'MODS')">
                                <compositionLevel>0</compositionLevel>
                            </xsl:when>
                            <xsl:otherwise>
                                <compositionLevel>1</compositionLevel>
                            </xsl:otherwise>
                        </xsl:choose>
                        <fixity>
                            <messageDigestAlgorithm>
                                <xsl:value-of select="foxml:contentDigest/@TYPE" />
                            </messageDigestAlgorithm>
                            <messageDigest>
                                <xsl:value-of select="foxml:contentDigest/@DIGEST" />
                            </messageDigest>
                        </fixity>
                        <size><xsl:value-of select="@SIZE"/></size>
                        <format>
                            <formatDesignation>
                                <formatName><xsl:value-of select="@MIMETYPE"/></formatName>
                            </formatDesignation>
                        </format>
                    </objectCharacteristics>
                    <storage>
                        <contentLocation>
                            <contentLocationType>Fedora Commons contentLocation REF value</contentLocationType>
                            <contentLocationValue><xsl:value-of select="foxml:contentLocation/@REF"/></contentLocationValue>
                        </contentLocation>
                    </storage>
                    <!-- There should only be one audit:auditTrail but this for-each loop accounts for multiple. -->
                    <xsl:for-each select="/foxml:digitalObject/foxml:datastream[@ID='AUDIT']/foxml:datastreamVersion/foxml:xmlContent/audit:auditTrail">
                        <xsl:for-each select="audit:record">
                            <!-- We're only interested in audit:records that document a PREMIS fixityEvent. -->
                            <xsl:if test="contains(audit:justification, concat('PREMIS:file=', $content_location))">
                                <xsl:variable name="responsibility" select="audit:responsibility" />
                                <xsl:variable name="date" select="audit:date" />
                                <xsl:variable name="justification" select="audit:justification" />
                                <linkingEventIdentifier>
                                    <linkingEventIdentifierType>Internal</linkingEventIdentifierType>
                                    <linkingEventIdentifierValue><xsl:value-of select="concat($datastream_id, ':', @ID)"/></linkingEventIdentifierValue>                                                                                         
                                </linkingEventIdentifier>
                            </xsl:if>
                        </xsl:for-each>  
                    </xsl:for-each>
                </object>
            </xsl:for-each>
       </xsl:for-each>
       
       <!-- Then their events. -->
       
       <xsl:comment>'Internal' eventIdentifierType values are comprised of Fedora datasteam ID plus ':' plus Fedora Audit Record ID.</xsl:comment>
       
        <xsl:for-each select="foxml:datastream[@CONTROL_GROUP='M']">
            <xsl:for-each select="foxml:datastreamVersion">
                <xsl:variable name="content_location" select="foxml:contentLocation/@REF" />
                <xsl:variable name="datastream_id" select="@ID" />
                    <!-- There should only be one audit:auditTrail but this for-each loop accounts for multiple. -->
                    <xsl:for-each select="/foxml:digitalObject/foxml:datastream[@ID='AUDIT']/foxml:datastreamVersion/foxml:xmlContent/audit:auditTrail">
                        <xsl:for-each select="audit:record">
                            <!-- We're only interested in audit:records that document a PREMIS fixityEvent. -->
                            <xsl:if test="contains(audit:justification, concat('PREMIS:file=', $content_location))">
                                <xsl:variable name="responsibility" select="audit:responsibility" />
                                <xsl:variable name="date" select="audit:date" />
                                <xsl:variable name="justification" select="audit:justification" />
                                <event>
                                    <eventIdentifier>
                                        <eventIdentifierType>Internal</eventIdentifierType>
                                        <eventIdentifierValue><xsl:value-of select="concat($datastream_id, ':', @ID)" /></eventIdentifierValue>
                                    </eventIdentifier>
                                        <eventType>fixity check</eventType>
                                        <eventDateTime><xsl:value-of select="$date" /></eventDateTime>
                                        <eventOutcomeInformation>
                                            <eventOutcome>
                                                <!-- eventOutcome should be coded, not free text. -->
                                                <xsl:value-of select="substring-after(audit:justification, 'PREMIS:eventOutcome=')" />
                                            </eventOutcome>
                                        </eventOutcomeInformation>
                                        <linkingAgentIdentifier>
                                          <linkingAgentIdentifierType><xsl:value-of select="$premis_agent_identifier_type" /></linkingAgentIdentifierType>
                                          <linkingAgentIdentifierValue><xsl:value-of select="$premis_agent_identifier_organization" /></linkingAgentIdentifierValue>
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
                <agentIdentifierType><xsl:value-of select="$premis_agent_identifier_type" /></agentIdentifierType>
                <agentIdentifierValue><xsl:value-of select="$premis_agent_identifier_organization" /></agentIdentifierValue>
            </agentIdentifier>
            <agentName><xsl:value-of select="$premis_agent_name_organization" /></agentName>
            <agentType><xsl:value-of select="$premis_agent_type_organization" /></agentType>
        </agent>
        <agent>
            <agentIdentifier>
                <agentIdentifierType>URI</agentIdentifierType>
                <agentIdentifierValue>http://www.fedora-commons.org/</agentIdentifierValue>
            </agentIdentifier>
            <agentName>Fedora Repository <xsl:value-of select="$fedora_commons_version" /></agentName>
            <agentType>software</agentType>
        </agent>
    
            <!-- rights metadata -->
            <rights>
                <rightsExtension><dc:rights><xsl:value-of select="/foxml:digitalObject/foxml:datastream/foxml:datastreamVersion[last()]/foxml:xmlContent/oai_dc:dc/dc:rights"/></dc:rights></rightsExtension>
            </rights>
       </premis>
    </xsl:template>

</xsl:stylesheet>
