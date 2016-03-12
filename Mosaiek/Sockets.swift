//
//  Sockets.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 3/11/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import Foundation
import SocketIOClientSwift

class Sockets {
   var openSockets:[(socket: SocketIOClient, socketID: String)] = []
    
    static let sharedInstance = Sockets();
    private init(){
        
    }
    
    func addSocket(socket:SocketIOClient,socketID:String){
        print("Adding socket ",socketID);
        self.openSockets.append((socket,socketID));
    }
    
    func removeSocket(socket:SocketIOClient){
        var socketIndex = -1;
        for (index, element) in self.openSockets.enumerate() {
            if (element.socket == socket){
                socketIndex = index;
                break;
            }
        }
        if (socketIndex > -1){
            print("Removing socket",self.openSockets[socketIndex].socketID);
            self.openSockets.removeAtIndex(socketIndex);
        }
    }
    
    func closeAllSockets(){
        print("Closing all sockets");
        for (var i = 0; i < self.openSockets.count; i++){
            print("emitting disconnect for ",self.openSockets[i].socketID);
            self.openSockets[i].socket.emit("disconnect",self.openSockets[i].socketID);
            self.openSockets[i].socket.disconnect();
        }
        
        self.openSockets.removeAll();
        //emit disconnect for each socket with room data
    }
    
}