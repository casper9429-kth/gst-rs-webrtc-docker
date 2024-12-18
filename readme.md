# Build, after change to dockerfile or first time
docker build -t my-ubuntu-image .

docker run -it --name my-ubuntu-container my-ubuntu-image


# Send test source to janus
gst-launch-1.0 videotestsrc !   janusvrwebrtcsink   signaller::room-id=1234   signaller::janus-endpoint=ws://3.125.87.172:8188/janus


# Send test source to whip 
RUST_BACKTRACE=full GST_DEBUG=webrtc*:3 GST_PLUGIN_PATH=target/x86_64-unknown-linux-gnu/debug:$GST_PLUGIN_PATH gst-launch-1.0 videotestsrc !   videoconvert !   video/x-raw !   queue !   whipclientsink name=ws signaller::whip-endpoint="http://3.125.87.172:7080/whip/endpoint/drone"


# Not tested

GST_DEBUG=3 gst-launch-1.0 -e uridecodebin uri=file:///videos/DJI_20241029113726_0001_V.MP4 !   decodebin !   videoconvert !   x264enc bitrate=5000 tune=zerolatency speed-preset=ultrafast !   video/x-h264,profile=high !   queue max-size-buffers=4 !   janusvrwebrtcsink   signaller::room-id=1234   signaller::janus-endpoint=ws://3.125.87.172:8188/janus


