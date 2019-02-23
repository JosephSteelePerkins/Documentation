-- this is an example of a table with an XML column

SELECT TOP (1000) [IllustrationID]
      ,[Diagram]
      ,[ModifiedDate]
  FROM [AdventureWorks].[Production].[Illustration]

-- the XML column is defined simple as XML

drop table [Production].[Illustration]

CREATE TABLE [Production].[Illustration](
    [IllustrationID] [int] IDENTITY (1, 1) NOT NULL,
    [Diagram] [XML] NULL, 
) ON [PRIMARY];
GO

-- how is the XML verified as it is loaded?
-- lets load in a file where I have messed with the XML

BULK INSERT [Production].[Illustration] FROM 'C:\Samples\AdventureWorks\IllustrationJoe.csv'
WITH (
    CHECK_CONSTRAINTS,
    CODEPAGE='ACP',
    DATAFILETYPE='widechar',
    FIELDTERMINATOR='+|',
    ROWTERMINATOR='&|\n',
    KEEPIDENTITY,
    TABLOCK
);

-- try a test file

drop table Diamond.dbo.XMLTest

Create table Diamond.dbo.XMLTest 
(XMLText XML (XMLTest)
)

truncate table Diamond.dbo.XMLTest 

BULK INSERT Diamond.dbo.XMLTest FROM 'C:\Users\User\Documentation\My Stuff\XMLTest.xml'

select  * from Diamond.dbo.XMLTest

-- the XML data type ensure the XML has the correct syntax
use Diamond
-- create a schema collection to hold the schema for XMLTest
CREATE XML SCHEMA COLLECTION XMLTest AS  
N'<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:element name="inventory">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="bikes">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="model" maxOccurs="unbounded" minOccurs="0">
                <xs:complexType mixed="true">
                  <xs:sequence>
                    <xs:element type="xs:float" name="price"/>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
        <xs:element name="skateboards">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="model" maxOccurs="unbounded" minOccurs="0">
                <xs:complexType mixed="true">
                  <xs:sequence>
                    <xs:element type="xs:float" name="price"/>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>' ;  

-- add it to the XML data type and it will verify the XML against the schema