import os
from azure.storage.blob import BlobServiceClient

CONNECTION_STRING = os.getenv('azure_msmch_conn')


def upload_file(fpath: str, container: str, target: str) ->None:
   filename = fpath.split('/')[-1]
   client = BlobServiceClient.from_connection_string(CONNECTION_STRING)
   container_client = client.get_container_client(container)
   blob_client = container_client.get_blob_client(target + "/" + filename)

   with open(fpath, "r", encoding="utf-8") as data:
      contents = data.read().encode("utf-8")
      blob_client.upload_blob(
         contents, 
         overwrite=True
      )
         
   return "File uploaded successfully"

