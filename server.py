from flask import Flask, jsonify
from obsws_python import ReqClient

app = Flask(__name__)

# OBS WebSocket connection details
host = "192.168.0.148"  # Your OBS machine's IP
port = 4455
password = "helloa"     # Your OBS WebSocket password

# Establish connection
ws = ReqClient(host=host, port=port, password=password)

@app.route("/start_recording", methods=["GET"])
def start_recording():
    try:
        ws.start_record()
        return jsonify({"status": "Recording started"})
    except Exception as e:
        return jsonify({"error": str(e)})

@app.route("/stop_recording", methods=["GET"])
def stop_recording():
    try:
        ws.stop_record()
        return jsonify({"status": "Recording stopped"})
    except Exception as e:
        return jsonify({"error": str(e)})

@app.route("/scenes", methods=["GET"])
def get_scenes():
    try:
        response = ws.get_scene_list()
        scenes = [scene.scene_name for scene in response.scenes]
        return jsonify({"scenes": scenes})
    except Exception as e:
        return jsonify({"error": str(e)})

@app.route("/status", methods=["GET"])
def status():
    try:
        response = ws.get_version()
        return jsonify({"connected": True, "obs_version": response.obs_version})
    except Exception as e:
        return jsonify({"connected": False, "error": str(e)})

@app.route("/switch_scene/<scene_name>", methods=["GET"])
def switch_scene(scene_name):
    try:
        ws.set_current_program_scene(scene_name=scene_name)
        return jsonify({"status": f"Switched to scene: {scene_name}"})
    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
