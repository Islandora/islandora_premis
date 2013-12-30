<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:foxml="info:fedora/fedora-system:def/foxml#"
    xmlns:audit="info:fedora/fedora-system:def/audit#" xmlns="info:lc/xmlns/premis-v2"
    exclude-result-prefixes="xs foxml audit" version="2.0">

    <!-- TO DO:
        * Incorporate LoC preservation events vocabulary where possible http://id.loc.gov/vocabulary/preservationEvents.html
    -->

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <xsl:strip-space elements="*"/>

    <xsl:include href="premis-object.xsl"/>
    <xsl:include href="premis-event.xsl"/>

    <!-- Locations of PREMIS schema files for easy maintenance.  Select which version of the data dictionary to use by passing parameter below to stylesheet at runtime. Defaults to PREMIS 2.1    -->
    <xsl:variable name="premis1-1" as="xs:string"
        >http://www.loc.gov/standards/premis/v1/PREMIS-v1-1.xsd</xsl:variable>
    <xsl:variable name="premis2-0" as="xs:string"
        >http://www.loc.gov/standards/premis/v2/premis-v2-0.xsd</xsl:variable>
    <xsl:variable name="premis2-1" as="xs:string"
        >http://www.loc.gov/standards/premis/v2/premis-v2-1.xsd</xsl:variable>

    <xsl:param name="premisVersion">2.1</xsl:param>

    <xsl:variable name="fedoraPID">
        <xsl:value-of select="/foxml:digitalObject/@PID"/>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$premisVersion = 1.1">
                <xsl:message>Backward support for PREMIS 1.1 not implemented yet. Most current
                    version (2.1) will be used instead.</xsl:message>
                <premis xsi:schemaLocation="info:lc/xmlns/premis-v2 {$premis2-1}"
                    version="{$premisVersion}">
                    <xsl:apply-templates/>
                </premis>
            </xsl:when>
            <xsl:when test="$premisVersion = 2.0">
                <premis xsi:schemaLocation="info:lc/xmlns/premis-v2 {$premis2-0}"
                    version="{$premisVersion}">
                    <xsl:apply-templates/>
                </premis>
            </xsl:when>
            <xsl:otherwise>
                <premis xsi:schemaLocation="info:lc/xmlns/premis-v2 {$premis2-1}"
                    version="{$premisVersion}">
                    <xsl:apply-templates/>
                </premis>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="foxml:objectProperties">
        <object xsi:type="">
            <xsl:call-template name="premisObject"/>
        </object>
    </xsl:template>

    <xsl:template match="audit:record">
        <event>
            <xsl:call-template name="premisEvent"/>
        </event>
    </xsl:template>

    <!-- Suppress output of everything except the audit datastream -->
    <xsl:template match="foxml:datastream[not(@ID='AUDIT')]"/>

</xsl:stylesheet>
