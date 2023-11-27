/////////////
// SETUP ////
/////////////

//wipe the slate
MATCH (n)
DETACH DELETE n;

//Create nodes for each type
UNWIND ['English', 'Swedish', 'Danish', 'Norwegian', 'German'] AS new_node_name
CREATE (node:Nationality {thing:new_node_name, lbl:"nationality"});

UNWIND ['red', 'green', 'yellow', 'blue', 'white'] AS new_node_name
CREATE (node:Color {thing:new_node_name, lbl:"color"});

UNWIND ['dogs', 'birds', 'cats', 'horses', 'fish'] AS new_node_name
CREATE (node:Pet {thing:new_node_name, lbl:"pet"});

UNWIND ['0', '1', '2', '3', '4'] AS new_node_name
CREATE (node:House {thing:new_node_name, lbl:"house"});

UNWIND ['Blend', 'Blue Masters', 'Dunhill', 'Pall Mall', 'Prince'] AS new_node_name
CREATE (node:Cigar {thing:new_node_name, lbl:"cigar"});

UNWIND ['milk', 'tea', 'coffee', 'beer', 'water'] AS new_node_name
CREATE (node:Drink {thing:new_node_name, lbl:"drink"});

//Assign direct hints                   
UNWIND [['English', 'red'],
 ['Swedish', 'dogs'],
 ['Danish', 'tea'],
 ['green', 'coffee'],
 ['Pall Mall', 'birds'],
 ['yellow', 'Dunhill'],
 ['2', 'milk'],
 ['Norwegian', '0'],
 ['Blue Masters', 'beer'],
 ['German', 'Prince'],
 ['Norwegian', 'blue']] AS pairz
WITH pairz
 MATCH (n1), (n2)
 WHERE n1.thing = pairz[0]
     AND n2.thing = pairz[1]
WITH n1, n2
 MERGE (n1)-[:PAIRED]-(n2);

//Assign undirected neighbor hints. Adjacency only
UNWIND [['green', 'white'], ['Blend', 'cats'], ['horses', 'Dunhill'], ['Blend', 'water']] as neighbs
WITH neighbs
MATCH (n1), (n2)
WHERE n1.thing = neighbs[0]
    AND n2.thing = neighbs[1]
WITH n1, n2
MERGE (n1)-[:NEIGHBORS]-(n2);

//Assign directed neighbor hint.
// Green is to the left of white.
MATCH (w:Color {thing:'white'}), (g:Color {thing:'green'})
MERGE (w)-[:SUPER_NEIGHBORS]->(g);
                         
//Set house types to integers for super_neighbor assignment
MATCH (h:House)
SET h.thing = toInteger(h.thing);

//Introduce neighbor relationships to houses. SUPER_NEIGHBORS is directed, showing the order along the street.
MATCH (house1:House), (house2:House)
WHERE house1.thing + 1 = house2.thing
MERGE (house2)-[:SUPER_NEIGHBORS]->(house1)
MERGE (house1)-[:NEIGHBORS]-(house2);
               
//every node is not paired to any of its own type: Each house only has one of each kind of thing
MATCH (n1), (n2)
WHERE n1.lbl = n2.lbl
    AND id(n1) <> id(n2)
MERGE (n1)-[:NOT_PAIRED]-(n2);
 
// Green cannot be House no 4, as it has to have white to the right. Likewise, House no 1 cannot be white, As it has to have green to the left (and 0 is taken by norwegian)
// This may end up being redundant with the concept of super_neighbors
//MATCH (g:Color {thing:'green'}), (h:House {thing:'4'})
//MERGE (h)-[:NOT_PAIRED]-(h);
//MATCH (w:Color {thing:'white'}), (h:House {thing:'1'})
//MERGE (w)-[:NOT_PAIRED]-(h);
                         
