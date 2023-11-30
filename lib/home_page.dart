import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/const.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WeatherFactory wf = WeatherFactory(OPENWEATHER_API_KEY);
  final _controller = StreamController<SwipeRefreshState>.broadcast();
  bool isRefresh = true;
  Stream<SwipeRefreshState> get _stream => _controller.stream;
  // List<Weather>? weather ;
  Weather? _weather;
fetchData ()async{
  LocationPermission permission = await Geolocator.checkPermission();
  if(permission != LocationPermission.denied){
    Position position =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.latitude.toString() +" "+ position.longitude.toString());
    _weather= await wf.currentWeatherByLocation(position.latitude, position.longitude);
  }else{
    _weather = await wf.currentWeatherByCityName("London");

  }
  if( permission == LocationPermission.denied){
    permission = await Geolocator.requestPermission();
    if(permission != LocationPermission.denied){
      Position position =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _weather= await wf.currentWeatherByLocation(position.latitude, position.longitude);
    }
  }
setState(() {

});
}
  @override
  void dispose() {
    _controller.close();

    super.dispose();
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(seconds:1));
    fetchData();
    _controller.sink.add(SwipeRefreshState.hidden);
    setState(() {

    });
  }
  @override
  void initState() {
    fetchData();
    super.initState();
  }
  var screenHeight,screenWidth;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body:_weather !=null ? SwipeRefresh.material(
        stateStream: _stream,
        onRefresh: _refresh,
        padding: const EdgeInsets.symmetric(vertical: 10),
        children:  [
          SizedBox(height: screenHeight*0.05,),
          _areaName(),
          SizedBox(height: screenHeight*0.05,),
          _dateTimeInfo(),
          SizedBox(height: screenHeight*0.05,),
          _sunRiseSunSet(),
          _weatherIconDetails(),
          SizedBox(height: screenHeight*0.05,),
          _tempInfo(),
          SizedBox(height: screenHeight*0.05,),
          _extraInfo(),
        ],
      ):const Center(child: CircularProgressIndicator(),),
    );
  }
  Widget _areaName(){
  return Text(_weather!.areaName ?? "",textAlign: TextAlign.center, style: const TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w700),);
  }
  Widget _dateTimeInfo(){
    DateTime dateTime =
    // DateTime.now();
    _weather!.date!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(DateFormat.jm().format(dateTime),style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold
        ),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat("EEEE").format(dateTime),style: const TextStyle(
              fontWeight: FontWeight.w700,fontSize: 16
            ),),
            const SizedBox(width: 5,),
            Text(DateFormat.yMMMd().format(dateTime),style: const TextStyle(
                fontWeight: FontWeight.w300,fontSize: 15
            ),),
          ]
    
    ), 
      ],
    );
  }
Widget _sunRiseSunSet(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("Sunrise ${DateFormat("h:m a").format(_weather!.sunrise!)}" ,style: const TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,),
        Text("Sunset ${DateFormat("h:m a").format(_weather!.sunset!)}" ,style: const TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,)
      ],
    );

}
  Widget _weatherIconDetails(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network( "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
        Text("${_weather!.weatherDescription}",
        style: const TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w700)
    )
      ],
    );

  }
  Widget _tempInfo(){
    return Column(
      children: [
        Text("${_weather!.temperature?.celsius?.toStringAsFixed(0)}° C ",
            style: const TextStyle(color: Colors.black,fontSize: 35,fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        Text("Feels like ${_weather!.tempFeelsLike?.celsius?.toStringAsFixed(0)}° C",
          style: const TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),

      ],
    );
  }
  Widget _extraInfo(){
  return Container(
    height: MediaQuery.sizeOf(context).height * 0.15,
    margin: const EdgeInsets.symmetric(vertical: 0,horizontal: 50),
    decoration: BoxDecoration(
      color: Colors.indigoAccent,
      borderRadius: BorderRadius.circular(15)
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Max : ${_weather!.tempMax!.celsius!.toStringAsFixed(0)}° C",textAlign: TextAlign.left,style: const TextStyle(color: Colors.white,fontSize: 15),),
            Text("Min : ${_weather!.tempMin!.celsius?.toStringAsFixed(0)}° C",textAlign: TextAlign.left,style: const TextStyle(color: Colors.white,fontSize: 15),),
          ],
        ),
        const SizedBox( height: 15,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Wind : ${_weather!.windSpeed!.toStringAsFixed(0)}m/s",textAlign: TextAlign.left,style: const TextStyle(color: Colors.white,fontSize: 15),),
            Text("Humidly : ${_weather!.humidity?.toStringAsFixed(0)}%",textAlign: TextAlign.left,style: const TextStyle(color: Colors.white,fontSize: 15),),
          ],
        ),
      ],
    ),
  );
  }




}
