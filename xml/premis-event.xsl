<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:foxml="info:fedora/fedora-system:def/foxml#"
    xmlns:audit="info:fedora/fedora-system:def/audit#" xmlns="info:lc/xmlns/premis-v2"
    exclude-result-prefixes="xs foxml audit" version="2.0">

    <xsl:template name="premisEvent">
        <xsl:call-template name="eventIdentifier"/>
        <xsl:apply-templates/>
        <xsl:call-template name="linkingAgentIdentifier"/>
        <xsl:call-template name="linkingObjectIdentifier"/>
    </xsl:template>

    <!-- PREMIS Data Dictionary 2.1 defines semantics of identifier types (line 19 below) as "A designation of the domain within which the event identifier is unique." Presumably the IDs of audit actions are unique within an audit trail. This could be as un-descriptive as "local" -->
    <xsl:template name="eventIdentifier">
        <eventIdentifier>
            <eventIdentifierType>
                <xsl:text>Audit datastream </xsl:text><xsl:value-of select="ancestor::foxml:datastreamVersion/@ID"/>
            </eventIdentifierType>
            <eventIdentifierValue>
                <xsl:value-of select="@ID"/>
            </eventIdentifierValue>
        </eventIdentifier>
    </xsl:template>

    <xsl:template match="audit:action">
        <eventType>
            <xsl:apply-templates/>
        </eventType>
    </xsl:template>

    <xsl:template match="audit:date">
        <eventDateTime>
            <xsl:apply-templates/>
        </eventDateTime>
    </xsl:template>

    <xsl:template match="audit:justification">
        <eventDetail>
            <xsl:apply-templates/>
        </eventDetail>
    </xsl:template>

    <xsl:template name="linkingAgentIdentifier">
        <linkingAgentIdentifier>
            <linkingAgentIdentifierType>
                <xsl:text>Audit datastream </xsl:text><xsl:value-of select="ancestor::foxml:datastreamVersion/@ID"/>
            </linkingAgentIdentifierType>
            <linkingAgentIdentifierValue>
                <xsl:value-of select="audit:responsibility"/>
            </linkingAgentIdentifierValue>
        </linkingAgentIdentifier>
    </xsl:template>


    <!-- Suppress extra output of elements referenced only by value -->
    <xsl:template match="audit:responsibility"/>
    <xsl:template match="audit:componentID"/>

</xsl:stylesheet>
