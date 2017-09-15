#pragma once

#include "ofxiOS.h"
#include <ARKit/ARKit.h>
#include "ofxARKit.h"

#define LENGTH 44100 * 3

class ARSoundObject {
public:
    
    int id;
    float buffer [LENGTH];
    int recPos;
    int playPos;
    int mode;
    
    int endPos;
    
    // methods
    void record(float * input, int bufferSize, int nChannels){
        
        if( mode == 1){
            for( int i = 0; i < bufferSize * nChannels; i++){
                if(recPos < LENGTH){
                    buffer[recPos] = input[i];
                    recPos++;
                    endPos = recPos;
                }else{
                    recPos = 0;
                }
            }
        }
    }

    void play(float * output, int bufferSize, int nChannels){

        if( mode == 2 ){
            
            if( playPos < endPos){
            
                for(int i = 0; i < bufferSize * nChannels; i++) {
                    if(playPos < LENGTH ) {
                        output[i] = buffer[playPos];
                        playPos++;
                    }else{
                        playPos= 0; // LOOP
                    }
                }
                
            }else{
                for(int i = 0; i < bufferSize * nChannels; i++) {
                    output[i] = 0;
                }
            }
            
        }else{
            for(int i = 0; i < bufferSize * nChannels; i++) {
                output[i] = 0;
            }
        }

    }

    
};

class ofApp : public ofxiOSApp {
    
public:
    
    ofApp (ARSession * session);
    ofApp();
    ~ofApp ();
    
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs &touch);
    void touchMoved(ofTouchEventArgs &touch);
    void touchUp(ofTouchEventArgs &touch);
    void touchDoubleTap(ofTouchEventArgs &touch);
    void touchCancelled(ofTouchEventArgs &touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    void audioIn( float * input, int bufferSize, int nChannels );
    void audioOut( float * output, int bufferSize, int nChannels );

    ofTrueTypeFont font;
    
    
    // ====== AR STUFF ======== //
    ARSession * session;
    ARCore::AnchorManagerRef anchors;
    ARRef processor;
    
    ofImage img;
    
    int lastId;
    int ARindex;
    
    // Collision
    int hitCount;
    int hitId;
    int lastHitCount;
    
    // Sound
    //ARSoundObject sndobj;
    vector<ARSoundObject> sndArray;
    float buffer[LENGTH]; // 録音バッファ
    int sampleRate;       // サンプリングレート
    int recPos;           // 録音位置
    int playPos;          // 再生位置
    int mode;             // 録音 or 再生モード
    
    //vector<float[]> bufferArray;
    
};


