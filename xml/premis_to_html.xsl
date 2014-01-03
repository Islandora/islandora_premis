<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:marc="info:lc/xmlns/premis-v2" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html"/>
	
	<xsl:template match="/">
		<html>
			<xsl:apply-templates/>
		</html>
	</xsl:template>
	
	<xsl:template match="premis">
		<table>
			<tr>
				<th NOWRAP="TRUE" ALIGN="RIGHT" VALIGN="TOP">
					objectIdentifier
        </th>
        <td>
          <xsl:value-of select="objectIdentifier"/>
        </td>
      </tr>
    </table>
  </xsl:template>
</xsl:stylesheet>
