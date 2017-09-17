#include "ofApp.h"



void logSIMD(const simd::float4x4 &matrix)
{
    std::stringstream output;
    int columnCount = sizeof(matrix.columns) / sizeof(matrix.columns[0]);
    for (int column = 0; column < columnCount; column++) {
        int rowCount = sizeof(matrix.columns[column]) / sizeof(matrix.columns[column][0]);
        for (int row = 0; row < rowCount; row++) {
            output << std::setfill(' ') << std::setw(9) << matrix.columns[column][row];
            output << ' ';
        }
        output << std::endl;
    }
    output << std::endl;
}

ofMatrix4x4 matFromSimd(const simd::float4x4 &matrix){
    ofMatrix4x4 mat;
    mat.set(matrix.columns[0].x,matrix.columns[0].y,matrix.columns[0].z,matrix.columns[0].w,
            matrix.columns[1].x,matrix.columns[1].y,matrix.columns[1].z,matrix.columns[1].w,
            matrix.columns[2].x,matrix.columns[2].y,matrix.columns[2].z,matrix.columns[2].w,
            matrix.columns[3].x,matrix.columns[3].y,matrix.columns[3].z,matrix.columns[3].w);
    return mat;
}

//--------------------------------------------------------------
ofApp :: ofApp (ARSession * session){
    this->session = session;
    cout << "creating ofApp" << endl;
}

ofApp::ofApp(){}

//--------------------------------------------------------------
ofApp :: ~ofApp () {
    cout << "destroying ofApp" << endl;
}

//--------------------------------------------------------------
void ofApp::setup() {
    ofBackground(127);
    
    img.load("OpenFrameworks.png");
    
    int fontSize = 8;
    if (ofxiOSGetOFWindow()->isRetinaSupportedOnDevice())
        fontSize *= 2;
    
    font.load("fonts/mono0755.ttf", fontSize);
    
    processor = ARProcessor::create(session);
    processor->setup();
    
    anchors = ARCore::ARAnchorManager::create(session);

    // frame buffer
    fbo.allocate(512, 512);
    
    // Collision
    hitCount = 0;
    lastHitCount = 0;
    hitId = 0;
    
    // Setup sound
    sampleRate = 44100;
    ofSoundStreamSetup(1, 1, this, sampleRate, LENGTH, 4);

    // setup ARSoundObjects
    ARSoundObject s;
    s.id = 0;
    s.mode = 0;
    s.recPos = 0;
    s.playPos = 0;
    sndArray.push_back(s);
    lastId = 0;
    
    // flags
    isRecording = false;
}


vector < matrix_float4x4 > mats;

//--------------------------------------------------------------
void ofApp::update(){
    
    processor->update();
    
    mats.clear();
    
    anchors->update();
    
}


ofCamera camera;
//--------------------------------------------------------------
void ofApp::draw() {
    ofEnableAlphaBlending();
    
    ofDisableDepthTest();
    processor->draw();
    ofEnableDepthTest();

    fbo.begin();
    ofClear(255, 255, 255, 0);
    ofPushMatrix();
    ofPushStyle();
    ofSetColor(255, 255, 255);
    ofTranslate(256, 256);
    ofRotate( ofGetFrameNum() );
    ofNoFill();
    ofDrawSphere(0, 0, 200);
    ofPopStyle();
    ofPopMatrix();
    fbo.end();

    
    hitCount = 0;
    ARindex = 0;
    nearestDist = 9999;
    // This loops through all of the added anchors.
    anchors->loopAnchors([=](ARObject obj) -> void {
       
        camera.begin();
        processor->setARCameraMatrices();
        ofPushMatrix();
        ofMultMatrix(obj.modelMatrix);

        ofVec3f cameraPos = processor->getCameraTransformMatrix().getTranslation();
        ofVec3f objPos    = obj.modelMatrix.getTranslation();
        
        ofRotate(90,0,0,1);
        ofScale(0.0001, 0.0001);

        float dist = ofDist(cameraPos.x, cameraPos.y, cameraPos.z, objPos.x, objPos.y, objPos.z);
        if( dist < 0.05 ){
            ofSetColor(255, 255, 0, 255);
            hitCount++;
            if( dist < nearestDist ){
                hitId = ARindex;
                nearestDist = dist;
            }
        }else{
            ofSetColor(255);
        }
        //img.draw(0, 0);
        fbo.draw(-128, -128);
        ofSetColor(255);

        ofPopMatrix();
        camera.end();
        
        ARindex++;
    });

    if( sndArray[hitId].mode != 1 && hitCount != lastHitCount ){
        
        if( hitCount > 0){
            sndArray[hitId].playPos = 0;
            sndArray[hitId].mode = 2;
        }else{
            sndArray[hitId].mode = 0;
            sndArray[hitId].playPos = 0;
        }
        
    }
    
    lastHitCount = hitCount;
    
    ofDisableDepthTest();
    // ========== DEBUG STUFF ============= //
    int w = MIN(ofGetWidth(), ofGetHeight()) * 0.6;
    int h = w;
    int x = (ofGetWidth() - w)  * 0.5;
    int y = (ofGetHeight() - h) * 0.5;
    int p = 0;
    
    x = ofGetWidth()  * 0.2;
    y = ofGetHeight() * 0.11;
    p = ofGetHeight() * 0.035;

    font.drawString("frame num      = " + ofToString( ofGetFrameNum() ),    x, y+=p);
    font.drawString("frame rate     = " + ofToString( ofGetFrameRate() ),   x, y+=p);
    //font.drawString("screen width   = " + ofToString( ofGetWidth() ),       x, y+=p);
    //font.drawString("screen height  = " + ofToString( ofGetHeight() ),      x, y+=p);
    font.drawString("audio In[]     = " + ofToString( sndArray[lastId].recPos ),             x, y+=p);
    font.drawString("audio Out[]    = " + ofToString( sndArray[hitId].playPos ),            x, y+=p);
    font.drawString("play mode      = " + ofToString( sndArray[hitId].mode ),               x, y+=p);
    font.drawString("hit count      = " + ofToString( hitCount ),           x, y+=p);
    font.drawString("last hit count = " + ofToString( lastHitCount ),       x, y+=p);
    font.drawString("lastId         = " + ofToString( lastId ),             x, y+=p);
    font.drawString("hitId          = " + ofToString( hitId ),            x, y+=p);
    //font.drawString("waveformBuffer = " + ofToString( waveformBuffer.size() ),x, y+=p);
    //font.drawString("waveformPlayPos= " + ofToString( waveformPlayPos ),x, y+=p);

    
}

//--------------------------------------------------------------
void ofApp::exit() {
    //
    cout << "exiting ofApp" << endl;
    sndArray.clear();
    ofSoundStreamStop();
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs &touch){
    
    if( touch.numTouches == 2 ){
        isRecording = true;
        recStartTime = ofGetElapsedTimeMillis();
    }else{
    }
 
    //anchors->addAnchor(ofVec2f(touch.x,touch.y));

    sndArray[lastId].mode = 1;
    sndArray[lastId].recPos = 0;
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs &touch){

    isRecording = false;
    
    anchors->addAnchor(ofVec2f(touch.x,touch.y));

    sndArray[lastId].mode = 0;

    
    // Prepare next object
    ARSoundObject s;
    s.id = sndArray.size();
    s.mode = 0;
    s.recPos = 0;
    s.playPos = 0;
    sndArray.push_back(s);
    lastId++;

}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs &touch){

    anchors->clearAnchors();

    sndArray.clear();
    ARSoundObject s;
    s.id = 0;
    s.mode = 0;
    s.recPos = 0;
    s.playPos = 0;
    sndArray.push_back(s);
    lastId = 0;
    
}

//--------------------------------------------------------------
void ofApp::audioIn(float *input, int bufferSize, int nChannels){

    sndArray[lastId].record(input, bufferSize, nChannels);

    if( isRecording &&
       ( ofGetElapsedTimeMillis() - recStartTime ) >= 2000 ){
        
        anchors->addAnchor(ofVec2f(ofGetWidth() * 0.5, ofGetHeight() * 0.5));
        
        //sndobj.mode = 0;
        sndArray[lastId].mode = 0;
        
        // 次のオブジェクトを準備
        ARSoundObject s;
        s.id = sndArray.size();
        s.mode = 0;
        s.recPos = 0;
        s.playPos = 0;
        sndArray.push_back(s);

        lastId++;

        sndArray[lastId].mode = 1;
        sndArray[lastId].recPos = 0;
        
        recStartTime = ofGetElapsedTimeMillis();

    }
    
}

//--------------------------------------------------------------
void ofApp::audioOut(float *output, int bufferSize, int nChannels){

     sndArray[hitId].play(output, bufferSize, nChannels);

}


//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}


//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs& args){
    
}


