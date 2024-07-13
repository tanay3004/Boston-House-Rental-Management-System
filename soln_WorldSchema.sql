use worldschema;


select max(GNP) 
from country
where GovernmentForm = "Republic";

/* Q9 */
SELECT Code, Name
FROM Country
WHERE Continent IN ('Asia', 'Africa');

/* 10 */
SELECT Code, Name
FROM Country
WHERE GovernmentForm  LIKE '%Republic%' ;

/* 11 */
SELECT Code, Name
FROM Country
WHERE IndepYear IS NULL;

/* 21 */
SELECT CountryCode
FROM City
group by CountryCode
having count(*) >=3;

 Select Code, Name, SurfaceArea, IndepYear
 from Country
 order by SurfaceArea ASC, IndepYear DESC;
