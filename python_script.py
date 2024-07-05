from flask import Flask, request, jsonify
import requests
import time

# Initialize the Flask application
app = Flask(__name__)
from flask_cors import CORS
CORS(app)

# Hugging Face API details
API_URL = "https://api-inference.huggingface.co/models/nlpconnect/vit-gpt2-image-captioning"
headers = {"Authorization": "Bearer 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"}

def query(filename):
    with open(filename, "rb") as f:
        data = f.read()
    
    retries = 5
    while retries > 0:
        response = requests.post(API_URL, headers=headers, data=data)
        result = response.json()
        
        if 'error' in result and 'currently loading' in result['error']:
            print("Model is loading, waiting and retrying...")
            time.sleep(result.get('estimated_time', 10))  # Wait for the estimated time or 10 seconds
            retries -= 1
        else:
            return result
    
    return {"error": "Model is still loading, please try again later."}

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "No image provided"}), 400

    # Read the image file
    image_file = request.files['image']
    image_path = 'temp_image.jpg'
    image_file.save(image_path)

    # Query the Hugging Face API
    result = query(image_path)

    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
