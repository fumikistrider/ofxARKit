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
    
    // Setup sound
    sampleRate = 44100;
    ofSoundStreamSetup(0, 1, this, sampleRate, LENGTH, 4);
    mode = 2;
    recPos = 0;
    playPos = 0;
    
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
    
    // This loops through all of the added anchors.
    anchors->loopAnchors([=](ARObject obj) -> void {
       
        camera.begin();
        processor->setARCameraMatrices();
        
        ofPushMatrix();
        ofMultMatrix(obj.modelMatrix);
        
        ofSetColor(255);
        ofRotate(90,0,0,1);
        ofScale(0.0001, 0.0001);
        img.draw(0,0);

        ofPopMatrix();
        
        camera.end();
        
    });
    
    
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
    font.drawString("screen width   = " + ofToString( ofGetWidth() ),       x, y+=p);
    font.drawString("screen height  = " + ofToString( ofGetHeight() ),      x, y+=p);
    
    
}

//--------------------------------------------------------------
void ofApp::exit() {
    //
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs &touch){
    anchors->addAnchor(ofVec2f(touch.x,touch.y));
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::audioIn(float *input, int bufferSize, int nChannels){
    
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


