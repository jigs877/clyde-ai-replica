import sys.ssl.Socket as SocketSSL;
import haxe.io.BytesOutput;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Bytes;
import hxdiscord.endpoints.Endpoints;

class OpenAIRequest {
    var socket:SocketSSL;
    var dataHttp:SomeBytes;
    public var timer:haxe.Timer;
    var respond:Bool = false;
    public function new() {

    }
    public function destroy() {
        socket.close();
        socket = null;
        respond = true;
    }

    public function chat(messages:Dynamic):String {
        //trace("is this being called or not");
        var models:Array<String> = ["gpt-3.5-turbo", "gpt-3.5-turbo-0301", "gpt-3.5-turbo-0613", "gpt-3.5-turbo-16k", "gpt-3.5-turbo-16k-0613"];
        //var model:String = models[Std.random(models.length)];
        var model:String = "gpt-3.5-turbo";
        //trace(model);
        dataHttp = new SomeBytes();
        socket = new SocketSSL();
        socket.connect(new sys.net.Host("api.openai.com"), 443);
        var stringBuf = new StringBuf();
        stringBuf.add("POST /v1/chat/completions HTTP/1.1\r\n");
        stringBuf.add("Host: api.openai.com\r\n");
        stringBuf.add("Content-Type: application/json\r\n");
        stringBuf.add("Authorization: Bearer "+Main.openai_token+"\r\n");
        stringBuf.add("User-Agent: " + Main.userAgent + "\r\n");
        stringBuf.add("Content-Length: " + haxe.Json.stringify({
            model: model,
            messages: messages,
            temperature: 1,
            frequency_penalty: 0,
            max_tokens: 1024,
            presence_penalty: 0,
            top_p: 1
        }).length + "\r\n");
        stringBuf.add("Connection: close\r\n\r\n");
        stringBuf.add(haxe.Json.stringify({
            model: model,
            messages: messages,
            temperature: 1,
            frequency_penalty: 0,
            max_tokens: 1024,
            presence_penalty: 0,
            top_p: 1
        }));
        //trace(stringBuf.toString());
        var bytes:Bytes = Bytes.ofString(stringBuf.toString());
        //trace(bytes.toString());
        socket.output.writeFullBytes(bytes, 0, bytes.length);
        var output:String = "";
        while (!respond) {
            var input = socket.input;
            var evenMoreBytes = new SomeBytes();
            try {
                var data = Bytes.alloc(1024);
                var readed = input.readBytes(data, 0, data.length);
                if (readed <= 0) break;
                evenMoreBytes.writeBytes(data.sub(0,readed));
                var bytes:Bytes = evenMoreBytes.readAllAvailableBytes();
                //trace(bytes);
                dataHttp.writeBytes(bytes);
                if (bytes.length == 0) {
                    respond = true;
                }
            } catch (err) {
                //trace(err);
                respond = true;
            }
        }
        var response = dataHttp.readAllAvailableBytes().toString();
        return response;
    }
}

class SomeBytes {
    public var available(default, null):Int = 0;
    private var currentOffset:Int = 0;
    private var currentData: Bytes = null;
    private var chunks:Array<Bytes> = [];

    public function new() {

    }

    public function writeBytes(data:Bytes) {
        chunks.push(data);
        available += data.length;
    }

    public function readAllAvailableBytes():Bytes {
        return readBytes(available);
    }

    public function readBytes(count:Int):Bytes {
        var count2 = Std.int(Math.min(count, available));
        var out = Bytes.alloc(count2);
        for (n in 0 ... count2) out.set(n, readByte());
        return out;
    }

    public function readByte():Int {
        if (available <= 0) throw 'Not bytes available';
        while (currentData == null || currentOffset >= currentData.length) {
            currentOffset = 0;
            currentData = chunks.shift();
        }
        available--;
        return currentData.get(currentOffset++);
    }
}