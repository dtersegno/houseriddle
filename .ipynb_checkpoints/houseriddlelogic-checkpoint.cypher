         
/////////////////                          
// REPEATABLES //
/////////////////

/////
// Inferenced relationships from other relationships.
// Any super neighbors are neighbors and supers
MATCH (n1)-[:SUPER_NEIGHBORS]->(n2)
MERGE (n1)-[:NEIGHBORS]-(n2)
MERGE (n1)-[:SUPERS]->(n2);
                       
// Any SUPERS and NEIGHBORS are SUPER_NEIGHBORS
MATCH (n2)-[:SUPERS]->(n1)-[:NEIGHBORS]-(n2)
MERGE (n2)-[:SUPER_NEIGHBORS]->(n1);
                                                       
// SUPERs transitivity                          
MATCH (n)-[:SUPERS]->(m)-[:SUPERS]->(o)
MERGE (n)-[:SUPERS]->(o);
                      
//any neighbors are not paired
MATCH (n1)-[:NEIGHBORS]-(n2)
MERGE (n1)-[:NOT_PAIRED]-(n2);
                          
//any paired are not neighbors
MATCH (n1)-[:PAIRED]-(n2)
MERGE (n1)-[:NOT_NEIGHBORS]-(n2);

                             
//////////                          
// Maximum numbers of relationships

// max 1 paired from one node to any other of a given type.
// every node paired with another, is not paired with all the others of the same type.
MATCH (n1)-[:PAIRED]-(n2), (another_n2_type)
WHERE n2.lbl = another_n2_type.lbl
    AND id(n2) <>  id(another_n2_type)
MERGE (n1)-[:NOT_PAIRED]-(another_n2_type);
                         
// max 2 neighbors of a single type from a given node.
// if a node neighbors two which are of the same type, it does not neighbor the remaining 3 of that type
MATCH (n3)-[:NEIGHBORS]-(n1)-[:NEIGHBORS]-(n2)
WHERE id(n3) <> id(n2)
    AND labels(n3) = labels(n2)
WITH n1, n2, n3, labels(n2) as neighbor_label
MATCH (n4)
WHERE id(n4) <> id(n1)
    AND id(n4) <> id(n2)
    AND id(n4) <> id(n3)
    AND labels(n4) = neighbor_label
MERGE (n1)-[:NOT_NEIGHBORS]-(n4);

// Houses 0 and 4 only have one neighbor
MATCH (n1:House)-[:NEIGHBORS]-(n2)
    WHERE n1.thing = 1 OR n1.thing = '1' //strings maybe not necessary, but what the hey
       OR n1.thing = 4 OR n1.thing = '4'
WITH n1, n2, labels(n2) as neighbor_label
MATCH (n3)
WHERE id(n3) <> id(n1)
    AND id(n3) <> id(n2)
    AND labels(n3) = neighbor_label
MERGE (n1)-[:NOT_NEIGHBORS]-(n3);                         
                             
//////// Inheritance                             
//PAIRS of two nodes inherit all relationships from each other.
                             
//Unfortunately, the following two blocks doesn't work.
//MATCH (n1)-[:PAIRED]-(n2)-[right_arrow]->(n3)
//WHERE id(n1) <> id(n3)
//WITH n1, n3, type(right_arrow) as new_type
//MERGE (n1)-[:new_type]->(n3);
                         
//MATCH (n1)-[:PAIRED]-(n2)<-[left_arrow]-(n3)
//WHERE id(n1) <> id(n3)
//WITH n1, n3, type(left_arrow) as new_type
//MERGE (n1)<-[:new_type]-(n3);

// For now just hard-coding each relationship type.
                             
MATCH (n1)-[:PAIRED]-(n2)-[:PAIRED]-(n3)
WHERE id(n1) <> id(n3)
MERGE (n1)-[:PAIRED]-(n3);
                      
MATCH (n1)-[:PAIRED]-(n2)-[:NEIGHBORS]-(n3)
WHERE id(n1) <> id(n3)
MERGE (n1)-[:NEIGHBORS]-(n3);
                         
MATCH (n1)-[:PAIRED]-(n2)-[:NOT_PAIRED]-(n3)
WHERE id(n1) <> id(n3)
MERGE (n1)-[:NOT_PAIRED]-(n3);

MATCH (n1)-[:PAIRED]-(n2)-[:SUPER_NEIGHBORS]->(n3)
WHERE id(n1) <> id(n3)
MERGE (n1)-[:SUPER_NEIGHBORS]->(n3);

MATCH (n1)-[:PAIRED]-(n2)<-[:SUPER_NEIGHBORS]-(n3)
WHERE id(n1) <> id(n3)
MERGE (n1)<-[:SUPER_NEIGHBORS]-(n3);
                                
MATCH (n1)-[:PAIRED]-(n2)-[:SUPERS]->(n3)
WHERE id(n1) <> id(n3)
MERGE (n1)-[:SUPERS]->(n3);

MATCH (n1)-[:PAIRED]-(n2)<-[:SUPERS]-(n3)
WHERE id(n1) <> id(n3)
MERGE (n1)<-[:SUPERS]-(n3);

MATCH (n1)-[:PAIRED]-(n2)-[:NOT_NEIGHBORS]-(n3)
WHERE id(n1) <> id(n3)
MERGE (n1)-[:NOT_NEIGHBORS]-(n3);

       
//processo of elimination                     
//process of elimination PAIRED assignment
// If there is only one of a type that isn't paired with a given node, they are paired.
MATCH (n), (c)
WHERE c.lbl = 'cigar'
    AND NOT (c)-[:NOT_PAIRED]-(n)
    AND id(n) <> id(c)
WITH n, collect(c) AS cigars
WHERE size(cigars) = 1
UNWIND cigars as c
MERGE (n)-[:PAIRED]-(c);
                     
MATCH (n), (c)
WHERE c.lbl = 'house'
    AND NOT (c)-[:NOT_PAIRED]-(n)
    AND id(n) <> id(c)
WITH n, collect(c) AS cigars
WHERE size(cigars) = 1
UNWIND cigars as c
MERGE (n)-[:PAIRED]-(c);
                     
MATCH (n), (c)
WHERE c.lbl = 'drink'
    AND NOT (c)-[:NOT_PAIRED]-(n)
    AND id(n) <> id(c)
WITH n, collect(c) AS cigars
WHERE size(cigars) = 1
UNWIND cigars as c
MERGE (n)-[:PAIRED]-(c);
                     
MATCH (n), (c)
WHERE c.lbl = 'pet'
    AND NOT (c)-[:NOT_PAIRED]-(n)
    AND id(n) <> id(c)
WITH n, collect(c) AS cigars
WHERE size(cigars) = 1
UNWIND cigars as c
MERGE (n)-[:PAIRED]-(c);
                     
MATCH (n), (c)
WHERE c.lbl = 'nationality'
    AND NOT (c)-[:NOT_PAIRED]-(n)
    AND id(n) <> id(c)
WITH n, collect(c) AS cigars
WHERE size(cigars) = 1
UNWIND cigars as c
MERGE (n)-[:PAIRED]-(c);
                     
MATCH (n), (c)
WHERE c.lbl = 'color'
    AND NOT (c)-[:NOT_PAIRED]-(n)
    AND id(n) <> id(c)
WITH n, collect(c) AS cigars
WHERE size(cigars) = 1
UNWIND cigars as c
MERGE (n)-[:PAIRED]-(c);