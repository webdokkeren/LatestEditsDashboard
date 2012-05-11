<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY CreatedToday "starts-with(@createDate, $today)">
	<!ENTITY UpdatedToday "starts-with(@updateDate, $today)">
	<!ENTITY CreatedYesterday "starts-with(@createDate, $yesterday)">
	<!ENTITY UpdatedYesterday "starts-with(@updateDate, $yesterday)">
]>
<?umbraco-package ?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:umb="urn:umbraco.library"
	exclude-result-prefixes="umb"
>

	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

	<xsl:param name="currentPage" />
	
	<!--
		Because we're running in a Dashboard, currentPage is AWOL, so we do some other hexerei instead.
	-->
	<xsl:variable name="absoluteRoot" select="umb:GetXmlNodeByXPath('/root')" />
	
	<!-- Do the date stuff -->
	<xsl:variable name="today" select="substring-before(umb:CurrentDate(), 'T')" />
	<xsl:variable name="yesterday" select="substring-before(umb:DateAdd($today, 'd', -1), 'T')" />

	<!-- Grab all nodes, so we're only "double-dashing" this once -->
	<xsl:variable name="nodes" select="$absoluteRoot//*[@isDoc]" />
	
	<!-- Check if XMLDump is active -->
	<xsl:variable name="hasXMLDump" select="boolean($nodes[xmldumpAllowedIPs])" />

	<!-- Select ourselves some nodes -->
	<xsl:variable name="nodesCreatedToday" select="$nodes[&CreatedToday;]" />
	<xsl:variable name="nodesUpdatedToday" select="$nodes[not(&CreatedToday;)][&UpdatedToday;]" />

	<xsl:variable name="nodesCreatedYesterday" select="$nodes[&CreatedYesterday;]" />
	<xsl:variable name="nodesUpdatedYesterday" select="$nodes[not(&CreatedYesterday;)][&UpdatedYesterday;]" />
	
	<!-- How much do we need to show at most? -->
	<xsl:variable name="itemsToShow" select="10" />

	<!-- Now let's do this -->
	<xsl:template match="/">
		
		<div class="dashboardWrapper">
			<h2>Latest edits</h2>
			<img src="/usercontrols/Vokseverk/LatestEditsDashboard/LatestEditsIcon_32x32.png" alt="Latest Edits Icon" class="dashboardIcon" />
				
			<h3>Pages created today:</h3>
			<div class="propertypane">
				<ol>
					<xsl:apply-templates select="$nodesCreatedToday">			
						<xsl:sort select="@createDate" data-type="text" order="descending" />
					</xsl:apply-templates>
					<xsl:if test="not($nodesCreatedToday)"><xsl:call-template name="noNodes" /></xsl:if>
				</ol>
			</div>		

			<h3>Pages updated today:</h3>
			<div class="propertypane">
				<ol>
					<xsl:apply-templates select="$nodesUpdatedToday">
						<xsl:sort select="@updateDate" data-type="text" order="descending" />
					</xsl:apply-templates>
					<xsl:if test="not($nodesUpdatedToday)"><xsl:call-template name="noNodes" /></xsl:if>
				</ol>
			</div>		
		
			<h3>Pages created yesterday:</h3>
			<div class="propertypane">
				<ol>
					<xsl:apply-templates select="$nodesCreatedYesterday">
						<xsl:sort select="@createDate" data-type="text" order="descending" />
					</xsl:apply-templates>
					<xsl:if test="not($nodesCreatedYesterday)"><xsl:call-template name="noNodes" /></xsl:if>
				</ol>
			</div>		
		
			<h3>Pages updated yesterday:</h3>
			<div class="propertypane">
				<ol>
					<xsl:apply-templates select="$nodesUpdatedYesterday">
						<xsl:sort select="@updateDate" data-type="text" order="descending" />
					</xsl:apply-templates>
					<xsl:if test="not($nodesUpdatedYesterday)"><xsl:call-template name="noNodes" /></xsl:if>
				</ol>
			</div>
		</div>
	</xsl:template>
	
	<!-- The main output template for each chunk of nodes -->
	<xsl:template name="outputSection">
		<xsl:param name="nodes" select="/.." /><!-- Default to an empty set -->
		<xsl:param name="action" select="'created'" />
		<xsl:param name="when" select="'today'" />
		
		<h3>
			<xsl:value-of select="concat('Pages ', $action, ' ', $when, ':')" />
		</h3>
		<div class="propertypane">
			<ol>
				<xsl:apply-templates select="$nodes">
					<xsl:sort select="@updateDate[$action = 'updated']" data-type="text" order="descending" />
					<xsl:sort select="@createDate[$action = 'created']" data-type="text" order="descending" />
				</xsl:apply-templates>
				<xsl:if test="not($nodes)"><xsl:call-template name="noNodes" /></xsl:if>
			</ol>
		</div>
	</xsl:template>
	
	<!-- This is the output template for each item -->
	<xsl:template match="*[@isDoc]">
		<xsl:if test="position() &lt;= $itemsToShow">
			<li>
				<span style="color:#999;"><xsl:value-of select="name()" /></span>
				<xsl:text>: </xsl:text>
				<span><xsl:value-of select="concat(@nodeName, ' ')" /></span>
				<xsl:apply-templates select="." mode="editLink" />
				<xsl:apply-templates select="." mode="xmldumpLink" />
			</li>
		</xsl:if>
	</xsl:template>
	
	<!-- Output if no nodes were created/updated -->
	<xsl:template name="noNodes">
		<li style="list-style-type:square;">(none)</li>
	</xsl:template>

	<xsl:template match="*[@isDoc]" mode="editLink">
		<a href="/umbraco/editContent.aspx?id={@id}" title="Click to edit...">Edit</a>
	</xsl:template>
	
	<xsl:template match="*[@isDoc]" mode="xmldumpLink">
		<xsl:if test="$hasXMLDump">
			<xsl:text> | </xsl:text>
			<a href="/xmldump?id={@id}" target="_blank" title="View XMLDump...">XML</a>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>