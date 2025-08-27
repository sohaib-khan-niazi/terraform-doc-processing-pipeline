import boto3
import json
import os
import urllib.parse
from datetime import datetime

s3 = boto3.client("s3")
textract = boto3.client("textract")
dynamodb = boto3.client("dynamodb")

def lambda_handler(event, context):
    try:
        # 1. Get bucket + file info from S3 event
        record = event["Records"][0]
        input_bucket = record["s3"]["bucket"]["name"]
        input_key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

        print(f"Processing file: s3://{input_bucket}/{input_key}")

        # 2. Call Textract (sync API)
        response = textract.detect_document_text(
            Document={"S3Object": {"Bucket": input_bucket, "Name": input_key}}
        )

        # 3. Extract only text lines (console-style)
        lines = [b["Text"] for b in response["Blocks"] if b["BlockType"] == "LINE"]
        clean_text = "\n".join(lines)

        # 4. Save plain text output to output bucket
        output_bucket = os.environ["OUTPUT_BUCKET"]
        output_key_txt = f"{input_key}.txt"

        s3.put_object(
            Bucket=output_bucket,
            Key=output_key_txt,
            Body=clean_text.encode("utf-8")
        )

        print(f"Saved extracted text to s3://{output_bucket}/{output_key_txt}")

        # 5. Generate presigned URL for demo
        url = s3.generate_presigned_url(
            "get_object",
            Params={"Bucket": output_bucket, "Key": output_key_txt},
            ExpiresIn=3600
        )
        print(f"Presigned URL (valid 1hr): {url}")

        # 6. Write metadata to DynamoDB
        table_name = os.environ["DYNAMODB_TABLE"]
        dynamodb.put_item(
            TableName=table_name,
            Item={
                "filename": {"S": input_key},
                "timestamp": {"S": datetime.utcnow().isoformat()},
                "status": {"S": "processed"},
                "output_txt": {"S": f"s3://{output_bucket}/{output_key_txt}"}
            }
        )

        print(f"Metadata written to DynamoDB table: {table_name}")

        return {
            "status": "success",
            "txt_output": f"s3://{output_bucket}/{output_key_txt}"
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {"status": "error", "message": str(e)}
