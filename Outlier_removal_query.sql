SELECT
  TIS,
  Model_year,
  model_line,
  mileage
FROM (
  SELECT
    *,
    CASE
      WHEN mileage<OUTLIER_PERCENTILE_80 THEN 'N'
    ELSE
    'Y'
  END
    AS OUTLIER_FLAG_80,
    CASE
      WHEN mileage>OUTLIER_PERCENTILE_20 THEN 'N'
    ELSE
    'Y'
  END
    AS OUTLIER_FLAG_20
  FROM (
    SELECT
      TIS,
      Model_year,
      model_line,
      mileage,
      PERCENTILE_CONT(mileage,
        0.80) OVER (PARTITION BY TIS, Model_year, model_line) AS OUTLIER_PERCENTILE_80,
      PERCENTILE_CONT(mileage,
        0.20) OVER (PARTITION BY TIS, Model_year, model_line) AS OUTLIER_PERCENTILE_20
    FROM (
      SELECT
        * EXCEPT(row_num,
          count)
      FROM (
        SELECT
          TIS,
          Model_year,
          model_linE,
          mileage,
          ROW_NUMBER() OVER(PARTITION BY TIS, Model_year, model_line) AS row_num,
          COUNT(*) OVER (PARTITION BY TIS, Model_year, model_line) AS count
        FROM
          `analytics-univ.vehicle.vehicle` )
      WHERE
        count > 100) ) )
WHERE
  OUTLIER_FLAG_80='N'
  AND OUTLIER_FLAG_20='N'