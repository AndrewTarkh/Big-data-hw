from prefect import flow, task
from prefect.cache_policies import NO_CACHE
from pyspark.sql import SparkSession
from pyspark.sql import functions as F


@task(name="start_spark_session", cache_policy=NO_CACHE)
def start_spark():
    spark = (
        SparkSession.builder
        .appName("PrefectSparkYARNJob")
        .master("yarn")
        .config("spark.submit.deployMode", "client")
        .config("spark.sql.warehouse.dir", "hdfs://team-02-nn:9000/user/hive/warehouse")
        .config("spark.hadoop.hive.metastore.uris", "")
        .enableHiveSupport()
        .getOrCreate()
    )
    return spark


@task(name="read_from_hdfs", cache_policy=NO_CACHE)
def read_data(spark: SparkSession, hdfs_path: str):
    df = (
        spark.read
        .option("header", "false")
        .csv(hdfs_path)
        .toDF("order_id", "category", "amount", "order_year")
    )
    return df


@task(name="transform_data", cache_policy=NO_CACHE)
def transform_data(df):
    typed_df = (
        df.withColumn("order_id", F.col("order_id").cast("int"))
        .withColumn("amount", F.col("amount").cast("double"))
        .withColumn("order_year", F.col("order_year").cast("int"))
        .withColumn("category", F.upper(F.trim(F.col("category"))))
        .filter(F.col("amount") > 0)
    )

    agg_df = (
        typed_df.groupBy("category", "order_year")
        .agg(
            F.count("order_id").alias("total_orders"),
            F.round(F.sum("amount"), 2).alias("total_sum"),
            F.round(F.avg("amount"), 2).alias("avg_amount"),
        )
    )
    return agg_df


@task(name="save_as_table", cache_policy=NO_CACHE)
def save_table(spark: SparkSession, df, db_name: str, table_name: str):
    spark.sql(f"CREATE DATABASE IF NOT EXISTS {db_name}")
    spark.sql(f"USE {db_name}")
    (
        df.write
        .mode("overwrite")
        .format("parquet")
        .partitionBy("order_year")
        .saveAsTable(f"{db_name}.{table_name}")
    )
    print("=== Result saved in Spark table ===")
    spark.sql(f"SELECT * FROM {db_name}.{table_name}").show()


@flow(name="hdfs-spark-yarn-etl")
def etl_flow():
    hdfs_input = "hdfs://team-02-nn:9000/user/hive/input/orders/orders.csv"
    spark = start_spark()
    try:
        raw_df = read_data(spark, hdfs_input)
        result_df = transform_data(raw_df)
        save_table(spark, result_df, "homework5", "orders_prefect_report")
    finally:
        spark.stop()


if __name__ == "__main__":
    etl_flow()