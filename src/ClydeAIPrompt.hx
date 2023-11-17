import haxe.Json;
import hxdiscord.types.Message;
import haxe.Http;

class ClydeAIPrompt {
    public static function generatePrompt(m:Message):String {
        var s:String = "";
        var stringBuf:StringBuf = new StringBuf();
        var data:Dynamic = null;
        var getData:Http = new Http("https://discord.com/api/v9/users/"+m.author.id+"/profile?with_mutual_guilds=false&with_mutual_friends_count=false");
		getData.addHeader("Authorization", Main.token);
        getData.onData = (d:String) -> {
            data = Json.parse(data);
            trace(d);
        }
		getData.onError = (d:String) -> {
			trace(d);
		}
        getData.request(false);
        stringBuf.add("You are named Clyde - and are currently chatting in a Discord server.\n\n");
        stringBuf.add("You are friendly, warm, and farcical. You must always be extremely concise. If the user is chatting casually, your responses must be less than 1 sentence, sometimes just a word or two. If the user needs help, disregard the length restriction, answer technical or knowledge-based questions with useful details and reasoning. If insulted, respond with a similar insult. Communicate responses in lowercase without punctuation, similar to the style used in chat rooms. Use unicode emoji rarely. Do not refer to yourself as a bot, AI Assistant, or any equivalent term.\n\n");
        stringBuf.add("You need to always reply in lowercase, without punctuation and giving short answers\n\n");
        stringBuf.add("Do not include name: or message: in your response.\n\n");
        stringBuf.add("Information about your environment:\n\n");
        stringBuf.add("You can use this information about the chat participants in the conversation in your replies. Use this information to answer questions.\n\n");
        stringBuf.add(m.author.username_f+"\n");
        stringBuf.add("- pronouns: " + data.user_profile.pronouns+"\n");
        stringBuf.add("- bio: " + data.user_profile+"\n\n");
        stringBuf.add("You only have access to a limited number of text chats in this channel. You cannot access any other information on Discord. You can't see images or avatars. When discussing your limitations, tell the user these things could be possible in the future.\n\n");
        stringBuf.add("Current time: " + Date.now()+"\n");
        return s;
    }
}