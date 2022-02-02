from google.cloud import bigquery
import os
from google.cloud.bigquery.client import Client
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


#refer to API key
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = r"C:\Users\jeffz\Downloads\planar-truck-322401-fa6532b913fc.json"

# Create a "Client" object
client = bigquery.Client()

# Construct a reference to the "hacker_news" dataset
dataset_ref = client.dataset("samples", project="bigquery-public-data")

# API request - fetch the dataset
dataset = client.get_dataset(dataset_ref)

# List all the tables in the "hacker_news" dataset
tables = list(client.list_tables(dataset_ref))

# Print names of all tables in the dataset (there are four!)
for table in tables:  
    print(table.table_id)

# Construct a reference to the "full" table
table_ref = dataset_ref.table("gsod")

# API request - fetch the table
table = client.get_table(table_ref)

# Print information on all the columns in the "full" table in the "hacker_news" dataset
table.schema

for item in table.schema:
    print(item)

# Preview the first five lines of the "full" table
client.list_rows(table, max_results=5).to_dataframe()

#query to get all data from Toronto (Wban # 4724)
query2 = """

        SELECT year, month, AVG(mean_temp) AS avgmonthtemp, SUM(total_precipitation) AS precip
        FROM `bigquery-public-data.samples.gsod`
        WHERE wban_number = 4724 
        GROUP BY year, month
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
TO_temp.loc[TO_temp.month == 1, 'month'] = "Jan"
TO_temp.loc[TO_temp.month == 2, 'month'] = "Feb"
TO_temp.loc[TO_temp.month == 3, 'month'] = "Mar"
TO_temp.loc[TO_temp.month == 4, 'month'] = "Apr"
TO_temp.loc[TO_temp.month == 5, 'month'] = "May"
TO_temp.loc[TO_temp.month == 6, 'month'] = "Jun"
TO_temp.loc[TO_temp.month == 7, 'month'] = "Jul"
TO_temp.loc[TO_temp.month == 8, 'month'] = "Aug"
TO_temp.loc[TO_temp.month == 9, 'month'] = "Sept"
TO_temp.loc[TO_temp.month == 10, 'month'] = "Oct"
TO_temp.loc[TO_temp.month == 11, 'month'] = "Nov"
TO_temp.loc[TO_temp.month == 12, 'month'] = "Dec"

#convert temp to celcius
TO_temp['mean_temp_C'] = (TO_temp['avgmonthtemp'] - 32) * 5/9
TO_temp['precip_mm']= TO_temp['precip']*25.4
#
#TO_temp.mean_temp.value_counts().head()

#plot historical monthly mean temperatures

sns.set_style('whitegrid')
#sns.color_palette("ch:s=.25,rot=-.25", as_cmap=True)
#ax= sns.stripplot(x='month',y='mean_temp_C',data=TO_temp)
#ax= sns.boxplot(x='month',y='mean_temp_C',data=TO_temp, order=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec"])
#ax.set(xlabel='Month', ylabel='Mean Temperature ($^\circ$C)',title = 'Mean Temperature by month in Toronto,CA (1929-2010), \n Pulled from Bigquery Public Datasets: GSOD')
#plt.show()
#
#ax= sns.boxplot(x='month',y='precip_mm',data=TO_temp, order=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec"],color = "blue")
#ax.set(xlabel='Month', ylabel='Total monthly precipitation (mm)',title = 'Days rained by month in Toronto,CA (1929-2010), \n Pulled from Bigquery Public Datasets: GSOD')
#plt.show()


fig, axes = plt.subplots(1, 2)
fig.suptitle('Monthly average temperature and total precipitation, Toronto, ON, Canada (1929-2010) \n Big Query Public Dataset')
sns.boxplot(ax=axes[0],x='month',y='mean_temp_C',data=TO_temp, order=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec"])
axes[0].set(xlabel='Month', ylabel='Mean Temperature ($^\circ$C)',title = '')
sns.boxplot(ax=axes[1], x='month',y='precip_mm',data=TO_temp, order=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec"],color = "blue")
axes[1].set(xlabel='Month', ylabel='Total monthly precipitation (mm)',title = '')
plt.show()


