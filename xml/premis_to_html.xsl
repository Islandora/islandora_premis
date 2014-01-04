<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:premis="info:lc/xmlns/premis-v2" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xsi premis">
	<xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>

	<xsl:strip-space elements="*" />
	
	<xsl:template match="/premis:premis">
		<table id="premis_object" class="collapsible">
			<tr><th colspan="2" bgcolor="#CCCCCC">PREMIS OBJECT</th></tr>
			<tr><th>Element Name</th><th>Element Value</th></tr>	
			<xsl:apply-templates select="premis:object[@xsi:type='file']"/>
		</table>
		<table id="premis_event" class="collapsible">
			<tr><th colspan="2" bgcolor="#CCCCCC">PREMIS EVENT</th></tr>
			<tr><th>Element Name</th><th>Element Value</th></tr>
				<xsl:apply-templates select="premis:event"/>
		</table>
		<table id="premis_agent" class="collapsible">
			<tr><th colspan="2" bgcolor="#CCCCCC">PREMIS AGENT</th></tr>
			<tr><th>Element Name</th><th>Element Value</th></tr>
				<xsl:apply-templates select="premis:agent"/>
		</table>
		<table id="premis_rights" class="collapsible">
			<tr><th colspan="2" bgcolor="#CCCCCC">PREMIS RIGHTS</th></tr>
			<tr><th>Element Name</th><th>Element Value</th></tr>
			<xsl:apply-templates select="premis:rights"/>
		</table>
	</xsl:template>
	<xsl:template match="premis:object[@xsi:type='file']">		
		<tr><td colspan="2" bgcolor="#CCCCCC"><xsl:value-of select="name(premis:objectIdentifier)"/></td></tr>
		<tr>
			<td><xsl:value-of select="name(premis:objectIdentifier/premis:objectIdentifierType)"/></td>
			<td><xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierType"/></td>
		</tr>
		<tr>
			<td><xsl:value-of select="name(premis:objectIdentifier/premis:objectIdentifierValue)"/></td>
			<td><xsl:value-of select="premis:objectIdentifier/premis:objectIdentifierValue"/></td>
		</tr>
		
		<tr><td colspan="2" bgcolor="#CCCCCC"><xsl:value-of select="name(premis:objectCharacteristics)"/></td></tr>
		<tr>
			<td><xsl:value-of select="name(premis:objectCharacteristics/premis:compositionLevel)"/></td>
			<td><xsl:value-of select="premis:objectCharacteristics/premis:compositionLevel"/></td>
		</tr>
		<tr><td colspan="2" bgcolor="#CCCCCC"><xsl:value-of select="name(premis:objectCharacteristics/premis:fixity)"/></td></tr>
		<tr>
			<td><xsl:value-of
				select="name(premis:objectCharacteristics/premis:fixity/premis:messageDigestAlgorithm)"/></td>
			<td><xsl:value-of select="premis:objectCharacteristics/premis:fixity/premis:messageDigestAlgorithm"/></td>
		</tr>
		<tr>
			<td><xsl:value-of
				select="name(premis:objectCharacteristics/premis:fixity/premis:messageDigest)"/></td>
			<td><xsl:value-of select="premis:objectCharacteristics/premis:fixity/premis:messageDigest"/></td>
		</tr>
		<tr>
			<td><xsl:value-of
				select="name(premis:objectCharacteristics/premis:size)"/></td>
			<td><xsl:value-of select="premis:objectCharacteristics/premis:size"/></td>
		</tr>
		<tr><td colspan="2" bgcolor="#CCCCCC"><xsl:value-of select="name(premis:objectCharacteristics/premis:format)"/></td></tr>
		<tr>
			<td><xsl:value-of
				select="name(premis:objectCharacteristics/premis:format/premis:formatDesignation/premis:formatName)"/></td>
			<td><xsl:value-of select="premis:objectCharacteristics/premis:format/premis:formatDesignation/premis:formatName"/></td>
		</tr>
		<tr><td colspan="2" bgcolor="#CCCCCC"><xsl:value-of select="name(premis:storage)"/></td></tr>
		<tr>
			<td><xsl:value-of
				select="name(premis:storage/premis:contentLocation/premis:contentLocationType)"/></td>
			<td><xsl:value-of select="premis:storage/premis:contentLocation/premis:contentLocationType"/></td>
		</tr>
		<tr>
			<td><xsl:value-of
				select="name(premis:storage/premis:contentLocation/premis:contentLocationValue)"/></td>
			<td><xsl:value-of select="premis:storage/premis:contentLocation/premis:contentLocationValue"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="premis:agent">
		<tr>
			<td><xsl:value-of select="name(premis:agentIdentifier/premis:agentIdentifierType)"/></td>
			<td><xsl:value-of select="premis:agentIdentifier/premis:agentIdentifierType"/></td>
		</tr>
		<tr>
			<td><xsl:value-of select="name(premis:agentIdentifier/premis:agentIdentifierValue)"/></td>
			<td><xsl:value-of select="premis:agentIdentifier/premis:agentIdentifierValue"/></td>
		</tr>
		<tr>
			<td><xsl:value-of select="name(premis:agentName)"/></td>
			<td><xsl:value-of select="premis:agentName"/></td>
		</tr>
		<tr>
			<td><xsl:value-of select="name(premis:agentType)"/></td>
			<td><xsl:value-of select="premis:agentType"/></td>
		</tr>
	</xsl:template>
	
	
</xsl:stylesheet>
