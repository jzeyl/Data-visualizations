from google.cloud import bigquery
import os
from google.cloud.bigquery.client import Client
import pandas as pd

#refer to API key
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = r"C:\Users\jeffz\Downloads\planar-truck-322401-fa6532b913fc.json"

# Create a "Client" object
client = bigquery.Client()

# Construct a reference to the "hacker_news" dataset
dataset_ref = client.dataset("noaa_gsod", project="bigquery-public-data")

# API request - fetch the dataset
dataset = client.get_dataset(dataset_ref)

# List all the tables in the "hacker_news" dataset
tables = list(client.list_tables(dataset))

# Print names of all tables in the dataset (there are four!)
for table in tables:  
    print(table.table_id)

# Construct a reference to the "full" table
table_ref = dataset_ref.table("gsod1929")

# API request - fetch the table
table = client.get_table(table_ref)

# Print information on all the columns in the "full" table in the "hacker_news" dataset
table.schema

# Preview the first five lines of the "full" table
client.list_rows(table, max_results=5).to_dataframe()

#query to get all data from Toronto (Wban # 4724)
query2 = """

        SELECT year, mean_temp, month, snow, wban_number
        FROM `bigquery-public-data.samples.gsod`
        WHERE wban_number = 4724 
        """

#FROM `bigquery-public-data.samples.gsod` LIMIT 1000

## Create a QueryJobConfig object to estimate size of query without running it

#dry_run_config = bigquery.QueryJobConfig(dry_run=True)
#
## API request - dry run query to estimate costs
#dry_run_query_job = client.query(query, job_config=dry_run_config)
#
#print("This query will process {} bytes.".format(dry_run_query_job.total_bytes_processed))

query_job = client.query(query2)

# API request - run the query, and return a pandas DataFrame
TO_temp = query_job.to_dataframe()

#check head of df
TO_temp.head()
#len(TO_temp["wban_number"].unique())

#convert temp to celcius
TO_temp['mean_temp_C'] = (TO_temp['mean_temp'] - 32) * 5/9

# What five cities have the most measurements?
TO_temp.mean_temp.value_counts().head()

#plot historical monthly mean temperatures
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_style('whitegrid')
#sns.color_palette("ch:s=.25,rot=-.25", as_cmap=True)
#ax= sns.stripplot(x='month',y='mean_temp_C',data=TO_temp)
ax= sns.boxplot(x='month',y='mean_temp_C',data=TO_temp)
ax.set(xlabel='Month', ylabel='Mean Temperature ($^\circ$C)',title = 'Mean Temperature by month in Toronto,CA (1929-2010), \n Pulled from Bigquery Public Datasets: GSOD')
plt.show()
