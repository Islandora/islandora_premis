<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:foxml="info:fedora/fedora-system:def/foxml#"
    xmlns:audit="info:fedora/fedora-system:def/audit#" xmlns="info:lc/xmlns/premis-v2"
    exclude-result-prefixes="xs foxml audit" version="2.0">

    <!-- Placeholder for generating PREMIS objects. This template doesn't do anything yet   -->
    <xsl:template name="premisObject">
        <objectIdentifier>
            <objectIdentifierType>Fedora PID</objectIdentifierType>
            <objectIdentifierValue>
                <xsl:value-of select="$fedoraPID"/>
            </objectIdentifierValue>
        </objectIdentifier>
        <!--<objectCategory><xsl:comment>representation, file, or bitstream</xsl:comment></objectCategory>-->
        <objectCharacteristics>
            <compositionLevel><xsl:comment>0 to 1-n; see pp. 45-46 of data
                dictionary</xsl:comment></compositionLevel>
            <format>
                <xsl:comment>Best practice is to use a format definition from a recognized
                    registry</xsl:comment>
                <formatDesignation>
                    <formatName> </formatName>
                </formatDesignation>
            </format>
        </objectCharacteristics>
    </xsl:template>

    <xsl:template name="linkingObjectIdentifier">
        <linkingObjectIdentifier>
            <linkingObjectIdentifierType>Fedora PID</linkingObjectIdentifierType>
            <linkingObjectIdentifierValue>
                <xsl:value-of select="$fedoraPID"/>
            </linkingObjectIdentifierValue>
            <linkingObjectRole>source <!-- a suggested value --></linkingObjectRole>
        </linkingObjectIdentifier>
    </xsl:template>

</xsl:stylesheet>
