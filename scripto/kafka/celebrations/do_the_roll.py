# get all the records from PG and do some random selection
import psycopg2 as pg
import pandas as pd
import pandas.io.sql as psql
import psycopg2.extras as extras
import sys

# con = psycopg2.connect(database="celebration", user="celebrate", password="forever", host="192.168.1.162", port="5432")
# print("Database opened successfully")    

# cur = con.cursor()
# cur.execute(f"insert into song(song_title,song_added,song_class,song_offset_start,song_offset_end,song_notes) values ('{title}',now(),'testing123', {offset_start},{offset_end},'hi');")
# con.commit()
# print("Record inserted successfully")
# con.close()


connection = pg.connect("host=192.168.1.162 dbname=celebration user=celebrate password=forever")
connection.autocommit = True

dataframe = psql.read_sql('SELECT * FROM song', connection)
#product_category = psql.read_sql_query('select * from product_category', connection)

# get next sequence for playlist
cursor = connection.cursor()
cursor.execute("SELECT nextval('playlist_seq');")
playlist_seq = cursor.fetchone()[0]
print(f"playlist_seq: {playlist_seq}")
print(type(playlist_seq))
cursor.close()

# pick only some
while True:
    df = dataframe
    df1 = df[df.song_class == "intro"].sample(n=2)
    df2 = df[df.song_class == "main"].sample(n=7)
    df3 = df[df.song_class == "finish"].sample(n=2)

    dff1 = pd.concat([df1,df2,df3])
    dff2 = dff1.drop(columns=['song_added','song_notes'])

    print(dff2[["song_id","song_title","song_class"]])
    
    cont = input("Do you like what you see? y/any > ")
    while cont.lower() not in ("y"):
        cont = input("Do you like what you see? y/any > ")
    if cont == "y":
        break


# https://medium.com/analytics-vidhya/part-4-pandas-dataframe-to-postgresql-using-python-8ffdb0323c09
# Define a function that handles and parses psycopg2 exceptions
def show_psycopg2_exception(err):
    # get details about the exception
    err_type, err_obj, traceback = sys.exc_info()    
    # get the line number when exception occured
    line_n = traceback.tb_lineno    
    # print the connect() error
    print ("\npsycopg2 ERROR:", err, "on line number:", line_n)
    print ("psycopg2 traceback:", traceback, "-- type:", err_type) 
    # psycopg2 extensions.Diagnostics object attribute
    #print ("\nextensions.Diagnostics:", err.diag)    
    # print the pgcode and pgerror exceptions
    #print ("pgerror:", err.pgerror)
    #print ("pgcode:", err.pgcode, "\n")

# Define function using psycopg2.extras.execute_batch() to insert the dataframe
def execute_batch(conn, datafrm, table, page_size=150):
    
    # Creating a list of tupples from the dataframe values
    tpls = [tuple(x) for x in datafrm.to_numpy()]
    
    # dataframe columns with Comma-separated
    cols = ','.join(list(datafrm.columns))
    
    # SQL query to execute
    sql = "INSERT INTO %s(%s) VALUES(%%s,%%s,%%s,%%s,%%s)" % (table, cols)
    cursor = conn.cursor()
    try:
        extras.execute_batch(cursor, sql, tpls, page_size)
        print("Data inserted using execute_batch() successfully...")
    except (Exception, pg.DatabaseError) as err:
        # pass exception to function
        show_psycopg2_exception(err)
        cursor.close()
        
execute_batch(conn=connection, datafrm=dff2, table="playlist", page_size=150)

# tired to add the playlist_id along the dataframe update, 
# newly added playlist will have this column values set to null, so it is easy to update it

cursor = connection.cursor()
cursor.execute(f"update playlist set playlist_id = {playlist_seq}, playlist_added = now() where playlist_id is null;")
cursor.close()
