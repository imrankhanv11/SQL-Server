--use practice database
USE Practice;

--creting clusters
CREATE CLUSTERED INDEX test_cluster
ON Department(DepartmentID);
--( we can't create cluster in this beacuase one table contain only one cluster that is primary is their is no primary key we can put one cluster)

--creating table for cluster index
CREATE TABLE forCluster(
	Id INT,
	Name VARCHAR(20),
	Department VARCHAR(20),
	City VARCHAR(30),
	country VARCHAR(20),
	Salary INT
);

--now we can create CLUSTER INDEX
CREATE CLUSTERED INDEX forClustertest
ON forCluster(Id);

--create NONCLUSTER INDEX
CREATE NONCLUSTERED INDEX forNonCluster
ON forCluster(Name);

--rename the cluster
EXEC sp_rename 'forCluster.forNonCluster','Noncluster','INDEX';

--crete unique cluster
CREATE UNIQUE CLUSTERED INDEX uniquecluster
ON forCluster(Department);
--(similar of cluster index because one table have only one cluster index)

--creating noncluster UNIQUE index
CREATE UNIQUE NONCLUSTERED INDEX uniquenoncluster
ON forCluster(Department);
--(in above we can't insert duplicate values)

--include coloum in non clustered index
CREATE NONCLUSTERED INDEX includecoloum
ON forCluster(Department)
INCLUDE (City,Country);

--filtered index
CREATE NONCLUSTERED INDEX filtered
ON forCluster(City)
WHERE City = 'Chennai';

--diable index
ALTER INDEX filtered
ON forCluster
DISABLE;

--enable index
ALTER INDEX filtered
ON forCluster
REBUILD;

--DIABLE ALL INDEX IN TABLE
ALTER INDEX ALL
ON forCluster
DISABLE;

--ENABLE ALL INDEX IN TABLE
ALTER INDEX ALL
ON forCluster
REBUILD;

--DROP CLUSTER
DROP INDEX filtered
ON forCluster;

--or

DROP INDEX IF EXISTS Noncluster
ON forCluster;

--index maintanence
--reorganize(light)
ALTER INDEX includecoloum
ON forCluster REORGANIZE;

--REBUILD(hevier, but better)
ALTER INDEX includecoloum
ON forCluster REBUILD;