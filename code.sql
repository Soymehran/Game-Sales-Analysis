
-- Section1

SELECT platform.platform_name, AVG(num_sales) as Average
FROM platform
         JOIN game_platform gp on platform.id = gp.platform_id
         JOIN region_sales rs on gp.id = rs.game_platform_id
GROUP BY platform.platform_name
ORDER BY Average DESC;
-- Section2

SELECT g.game_name,
       p.platform_name,
       gp.release_year,
       pub.publisher_name,
       sum(rs.num_sales) as global_sales
FROM game_platform gp
         JOIN game_publisher gpub on gp.game_publisher_id = gpub.id
         JOIN game g on gpub.game_id = g.id
         JOIN publisher pub on gpub.publisher_id = pub.id
         JOIN platform p on gp.platform_id = p.id
         JOIN region_sales rs on gp.id = rs.game_platform_id
GROUP BY g.game_name, p.platform_name, gp.release_year, pub.publisher_name
ORDER BY global_sales DESC
limit 20;


-- Section3

SELECT g.game_name, COUNT(DISTINCT gp.platform_id) platform_count
FROM game_platform gp
         JOIN game_publisher gpub on gp.game_publisher_id = gpub.id
         JOIN game g on g.id = gpub.game_id
GROUP BY g.game_name
HAVING platform_count > 5
ORDER BY platform_count DESC,
         game_name ASC;

-- Section4

SELECT p.platform_name platform,
       gen.genre_name genre,
       DENSE_RANK() OVER (PARTITION BY p.id ORDER BY SUM(rs.num_sales) DESC) genre_in_platform_rank,
       SUM(rs.num_sales) genre_sale,
       DENSE_RANK() OVER (ORDER BY SUM(rs.num_sales) DESC) total_rank
FROM platform p
         JOIN
     game_platform gp ON p.id = gp.platform_id
         JOIN
     game_publisher gpub ON gpub.id = gp.game_publisher_id
         JOIN
     game g ON gpub.game_id = g.id
         JOIN
     genre gen ON g.genre_id = gen.id
         JOIN
     region_sales rs ON gp.id = rs.game_platform_id
GROUP BY p.platform_name, gen.genre_name, p.id
ORDER BY genre_sale DESC, platform_name, genre_name;
-- Section5

SELECT game_name, region_name, total_sales, rank_in_region
FROM (
    SELECT
        g.game_name,
        r.region_name,
        SUM(rs.num_sales) AS total_sales,
        DENSE_RANK() OVER (PARTITION BY r.region_name ORDER BY SUM(rs.num_sales) DESC) AS rank_in_region
    FROM region_sales rs
    JOIN game_platform gp ON rs.game_platform_id = gp.id
    JOIN region r ON rs.region_id = r.id
    JOIN game_publisher gpub ON gp.game_publisher_id = gpub.id
    JOIN game g ON gpub.game_id = g.id
    GROUP BY g.game_name, r.region_name
) t
WHERE rank_in_region <= 10
ORDER BY region_name, total_sales DESC, game_name;

-- Section6


SELECT
    g.game_name,
    GROUP_CONCAT(
                    pub.publisher_name
                 ORDER BY pub.publisher_name
                 SEPARATOR ',') AS publishers
FROM game_publisher gp
JOIN game g ON g.id = gp.game_id
JOIN publisher pub ON pub.id = gp.publisher_id
GROUP BY g.game_name
having COUNT(pub.publisher_name) > 1
ORDER BY g.game_name;
