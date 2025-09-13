from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from PIL import Image
from torchvision import transforms
import requests
import time
import ast
from vision_processes import forward
from image_patch import ImagePatch, llm_query, best_image_match, distance, bool_to_yesno

app = FastAPI()

MAX_RETRIES = 3  # Number of retries allowed

# Helper function to load image
def load_image(file: UploadFile):
    image = Image.open(file.file).convert('RGB')
    return transforms.ToTensor()(image)

# Helper function to generate code
def get_code(query):
    model_name_codex = 'hominiscode'
    code = forward(model_name_codex, prompt=query, input_type="image")
    code = ast.unparse(ast.parse(code))
    return code

# API Endpoint
@app.post("/preset/image/")
async def process_image(query: str = Form(...), image: UploadFile = File(...)):
    try:
        # Load the image
        im = load_image(image)

        # Initialize retry count
        retry_count = 0

        while retry_count < MAX_RETRIES:
            try:
                # Generate code
                code = get_code(query)
                code = code.replace('execute_command(image, my_fig, time_wait_between_lines, syntax)', 'execute_command(image)')
                
                # Execute code and fetch result
                exec(compile(code, 'hominiscode', 'exec'), globals())
                result = globals()['execute_command'](im)
                break  # Exit loop if execution is successful
            except AttributeError as e:
                retry_count += 1
                if retry_count == MAX_RETRIES:
                    code = None
                    result = "Cannot run analysis for this query image pair"
                else:
                    time.sleep(1)  # Optional delay between retries

        # Prepare response
        response = {
            "query": query,
            "code": code,
            "result": result
        }
        return JSONResponse(content=response)
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)
