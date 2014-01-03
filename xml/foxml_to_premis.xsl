<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:php="http://php.net/xsl" xsl:extension-element-prefixes="php"
  xmlns:foxml="info:fedora/fedora-system:def/foxml#" xmlns:audit="info:fedora/fedora-system:def/audit#"
  xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:fedora-model="info:fedora/fedora-system:def/model#"
  xmlns:islandora="http://islandora.ca/ontology/relsext#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  exclude-result-prefixes="php fedora fedora-model foxml audit islandora php rdf">

<xsl:output method="xml" encoding="utf-8" indent="yes"/>

<!-- Define a global parameter containing the Islandora object's PID. -->
<xsl:param name = "pid" select="foxml:digitalObject/@PID" />

<!-- Global parameters exported from out solution pack. -->
<xsl:param name="premis_agent_name_organization" />
<xsl:param name="premis_agent_identifier_organization" />
<xsl:param name="premis_agent_type_organization" />

<xsl:preserve-space elements="*" />

<xsl:template match="foxml:digitalObject">
    <premis xmlns="info:lc/xmlns/premis-v2" xsi:schemaLocation="info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/v2/premis.xsd" version="2.2">
    
    <xsl:comment>PREMIS data for Islandora object <xsl:value-of select="$pid" />. Contains object entries for each Managed datastream
    in an Islandora object, and event entries documenting all fixity checks performed on versions of those datastreams.
    Note that a datastream version that has never had a fixity check performed on it will not be linked to any fixity
    check events.</xsl:comment>

    <!-- Agents first. --> 
<!--
    <agent>
        <agentIdentifier>
            <agentIdentifierType>repository code</agentIdentifierType>
            <agentIdentifierValue><xsl:value-of select="$premis_agent_identifier_organization" /></agentIdentifierValue>
        </agentIdentifier>
        <agentName><xsl:value-of select="$premis_agent_name_organization" /></agentName>
        <agentType><xsl:value-of select="$premis_agent_type_organization" /></agentType>
    </agent>
-->

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
                    <compositionLevel>0</compositionLevel>
                    <fixity>
                    <!-- Currently not working... -->
                    <xsl:comment>@todo: Get messageDigestAlgorithm and messageDigest working.</xsl:comment>
                    <messageDigestAlgorithm>
                        <xsl:value-of select="foxml:contentDigest/@TYPE" />
                    </messageDigestAlgorithm>
                    <messageDigest>
                        <!-- Currently not working... -->
                        <xsl:value-of select="foxml:contentDigest/@DIGEST" />
                    </messageDigest>
                    </fixity>
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
                            </event>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
       </xsl:for-each>  
    </xsl:for-each>
   
   </premis>
</xsl:template>

</xsl:stylesheet>
