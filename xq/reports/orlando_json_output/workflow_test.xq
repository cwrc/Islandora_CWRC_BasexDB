(:
* A test that will return JSON for the query:
* select all workflow (within document) items and test dates
* https://www.mail-archive.com/basex-talk@mailman.uni-konstanz.de/msg04392.html 
:)

(: main section:)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";



<json type="array" objects="_">
  {
  for $item in /*
    return
      <_>
        <id>{data($item/@BI_ID) || data($item/@EID) || $item//STANDARD/text()}</id>     
        <type>{$item/name()}</type>     
        <responsibilities type="array"> 
          {
          for $wfItem in $item//RESPONSIBILITY
          return <_><date>{$wfItem/DATE/@VALUE/string()}</date></_>
        }
        </responsibilities>
       </_>

  }
  
</json>