import haxe.Json;
import haxe.Timer;
import haxe.EntryPoint;
import hxdiscord.DiscordClient;
import sys.io.File;
import sys.FileSystem;
import hxdiscord.utils.Intents;
import hxdiscord.types.*;
import haxe.Http;

using StringTools;

class Main {
	public static var Bot:DiscordClient;
	public static var userAgent:String = "ClydeAIReplica/1.0 (DiscordBot; +NULL)";
	public static var usersOnCooldownAI:Array<String> = [];
	public static var aiMessages:Map<String, Message> = new Map<String, Message>();
	public static var token:String = "";
	public static var openai_token:String = "";

	static function main() {
		if (!FileSystem.exists("config.json")) {
			File.saveContent(haxe.Json.stringify({
				token: "DISCORD TOKEN HERE",
				openai_token: "OPENAI TOKEN HERE"
			}), "\t");
			throw "Config file doesn't exist, the application has generated a new one\nMake sure to edit the new config.json file";
		} else {
			var content:String = File.getContent("config.json");
			var parse:Dynamic = Json.parse(content);
			token = parse.user_token;
			openai_token = parse.openai_token;
		}
		Bot = new DiscordClient(token, [Intents.ALL], false);
		Bot.onReady = onReady;
		Bot.onMessageCreate = onMessageCreate;
		Bot.connect();
	}

	public static function onReady() {
		trace("Clyde is ready to chat with people!");
	}

	public static function onMessageCreate(m:Message) {
		sys.thread.Thread.create(() -> {
			if ((m.content.contains("<@" + Bot.user.id + ">")
				|| m.content.contains("<!@" + Bot.user.id + ">")
				|| m.content.contains("<@!" + Bot.user.id + ">"))
				&& m.author.bot == null) {
				if (!usersOnCooldownAI.contains(m.author.id)) {
					OpenAIChat.chat(m);
				} else {
					m.reply({content: "Clyde didn't reply yet! Please wait"}, true);
				}
			} else {
				if (m.referenced_message != null && m.author.bot == null) {
					if (aiMessages.exists(m.referenced_message.id)) {
						OpenAIChat.chat(m);
					}
					if (OpenAIChat.threads.exists(m.channel_id)) {
						OpenAIChat.chat(m);
					}
				} else {
					if (OpenAIChat.threads.exists(m.channel_id)) {
						OpenAIChat.chat(m);
					}
				}
			}
		});
	}
}
