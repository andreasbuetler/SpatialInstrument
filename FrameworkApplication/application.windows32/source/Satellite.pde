




class Satellite {

float latitude;
float longitude;
String id;
String token;
JSONObject location;
boolean beatActive;
XML weatherData;
float windSpeed;



Satellite(JSONObject constructor){
  
this.id =getName(constructor);
this.token=getToken(this.id);
this.location =getLoc(this.id);
this.latitude=this.location.getFloat("lat");
this.longitude=this.location.getFloat("lon");
println("CONNECTED "+this.id );
this.beatActive=false;
weatherData=getWeatherData(this.longitude, this.latitude);
XML con = this.weatherData.getChild("weather/hourly/windspeedKmph");
// println("WINDSPEED"+con.getContent("windspeedKmph"));

this.windSpeed=  float(con.getContent("windspeedKmph"));
}
String getName(JSONObject _constructor){

  String name=_constructor.getJSONObject("connection").getString("name");

  return name;
}

JSONObject getLoc(String _name){
   JSONObject loc=new JSONObject();
  String[] ip= splitTokens(_name, " ");
  String[]  ipLoc=loadStrings("http://ip-api.com/json/"+ ip[0]);
  loc=loadJSONObject("http://ip-api.com/json/"+ ip[0]);
  //println("LOCATION JSON" +loc);

return loc;
}
String getToken(String _id){
String[] split_ =splitTokens(_id," ");
//printArray(split_);
return split_[2];
}

XML getWeatherData(float _lon, float _lat){
String url = "http://api.worldweatheronline.com/premium/v1/marine.ashx?key=";
String apiKey = "8123455eee72461aa4a63337202004";

String cord= str(_lon) +","+str(_lat);
String query = "&format=xml";
XML data;
    data=loadXML(url+apiKey+"&q="+cord+query);
    println((url+apiKey+"&q="+cord+query));
  return data;

  
}

}
