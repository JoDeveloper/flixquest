// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cinemax/api/endpoints.dart';
import 'package:cinemax/constants/api_constants.dart';
import 'package:cinemax/modals/credits.dart';
import 'package:cinemax/modals/function.dart';
import 'package:cinemax/modals/genres.dart';
import 'package:cinemax/modals/images.dart';
import 'package:cinemax/modals/tv.dart';
import 'package:cinemax/modals/tv_genres.dart';
import 'package:cinemax/modals/videos.dart';
import 'package:cinemax/screens/person_detail.dart';
import 'package:cinemax/screens/tv_detail.dart';
import 'package:cinemax/screens/genre_tv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'genremovies.dart';

class MainTVDisplay extends StatelessWidget {
  const MainTVDisplay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          const DiscoverTV(),
          ScrollingTV(
            title: 'Popular',
            api: Endpoints.popularTVUrl(1),
            discoverType: 'popular',
            isTrending: false,
          ),
          ScrollingTV(
            title: 'Trending',
            api: Endpoints.trendingTVUrl(1),
            discoverType: 1,
            isTrending: true,
          ),
          ScrollingTV(
            title: 'Top Rated',
            api: Endpoints.topRatedTVUrl(1),
            discoverType: 'top_rated',
            isTrending: false,
          ),
          ScrollingTV(
            title: 'Airing today',
            api: Endpoints.airingTodayUrl(1),
            discoverType: 'airing_today',
            isTrending: false,
          ),
          ScrollingTV(
            title: 'On the air',
            api: Endpoints.onTheAirUrl(1),
            discoverType: 'on_the_air',
            isTrending: false,
          ),
          // GenreListGrid(api: Endpoints.genresUrl()),
        ],
      ),
    );
  }
}

class DiscoverTV extends StatefulWidget {
  const DiscoverTV({Key? key}) : super(key: key);
  @override
  _DiscoverTVState createState() => _DiscoverTVState();
}

class _DiscoverTVState extends State<DiscoverTV>
    with AutomaticKeepAliveClientMixin {
  late double deviceHeight;
  late double deviceWidth;
  late double deviceAspectRatio;

  List<TV>? tvList;
  // MovieDetails? movieDetails;
  @override
  void initState() {
    super.initState();
    fetchTV(Endpoints.discoverTVUrl(1)).then((value) {
      setState(() {
        tvList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    deviceAspectRatio = MediaQuery.of(context).size.aspectRatio;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Discover',
                style: TextStyle(fontSize: deviceHeight * 0.036),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: deviceHeight * 0.45,
          child: tvList == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CarouselSlider.builder(
                  options: CarouselOptions(
                    disableCenter: true,
                    viewportFraction: 0.8,
                    enlargeCenterPage: true,
                    autoPlay: true,
                  ),
                  itemBuilder:
                      (BuildContext context, int index, pageViewIndex) {
                    return Container(
                      child: GestureDetector(
                        onTap: () {
                          // fetchMovieDetails(moviesList![index].id!);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TVDetailPage(
                                      tvSeries: tvList![index],
                                      heroId: '${tvList![index].id}discover')));
                        },
                        child: Hero(
                          tag: '${tvList![index].id}discover',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: FadeInImage(
                              image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                  'w500/' +
                                  tvList![index].posterPath!),
                              fit: BoxFit.cover,
                              placeholder:
                                  const AssetImage('assets/images/loading.gif'),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: tvList!.length,
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTV extends StatefulWidget {
  final String? api, title;
  final dynamic discoverType;
  final String? watchProviderId;
  final bool isTrending;
  const ScrollingTV({
    Key? key,
    this.api,
    this.title,
    this.discoverType,
    this.watchProviderId,
    required this.isTrending,
  }) : super(key: key);
  @override
  _ScrollingTVState createState() => _ScrollingTVState();
}

class _ScrollingTVState extends State<ScrollingTV>
    with AutomaticKeepAliveClientMixin {
  late double deviceHeight;
  late double deviceWidth;
  late double deviceAspectRatio;
  late int index;
  List<TV>? tvList;
  // MovieDetails? movieDetails;
  final ScrollController _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });
        if (widget.isTrending == false) {
          var response = await http.get(
            Uri.parse(
                "$TMDB_API_BASE_URL/tv/${widget.discoverType}?api_key=$TMDB_API_KEY&page=" +
                    pageNum.toString()),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistMovies = (json.decode(response.body)['results'] as List)
                .map((i) => TV.fromJson(i))
                .toList();
            tvList!.addAll(newlistMovies);
          });
        } else if (widget.isTrending == true) {
          var response = await http.get(
            Uri.parse(
                "$TMDB_API_BASE_URL/trending/tv/week?api_key=$TMDB_API_KEY&language=en-US&include_adult=false&page=" +
                    pageNum.toString()),
          );
          setState(() {
            pageNum++;
            isLoading = false;
            var newlistMovies = (json.decode(response.body)['results'] as List)
                .map((i) => TV.fromJson(i))
                .toList();
            tvList!.addAll(newlistMovies);
          });
        }
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    fetchTV(widget.api!).then((value) {
      setState(() {
        tvList = value;
      });
    });

    getMoreData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double deviceFont = MediaQuery.of(context).textScaleFactor;
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title!,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          height: 250,
          child: tvList == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: tvList!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TVDetailPage(
                                            tvSeries: tvList![index],
                                            heroId:
                                                '${tvList![index].id}${widget.title}')));
                              },
                              child: SizedBox(
                                width: 105,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 6,
                                      child: Hero(
                                        tag:
                                            '${tvList![index].id}${widget.title}',
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child:
                                              tvList![index].posterPath == null
                                                  ? Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : FadeInImage(
                                                      image: NetworkImage(
                                                          TMDB_BASE_IMAGE_URL +
                                                              'w500/' +
                                                              tvList![index]
                                                                  .posterPath!),
                                                      fit: BoxFit.cover,
                                                      placeholder: const AssetImage(
                                                          'assets/images/loading.gif'),
                                                    ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          tvList![index].name!,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                      child: Visibility(
                        child: const SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(),
                        ),
                        visible: isLoading,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ScrollingTVArtists extends StatefulWidget {
  final String? api, title, tapButtonText;
  const ScrollingTVArtists({
    Key? key,
    this.api,
    this.title,
    this.tapButtonText,
  }) : super(key: key);
  @override
  _ScrollingTVArtistsState createState() => _ScrollingTVArtistsState();
}

class _ScrollingTVArtistsState extends State<ScrollingTVArtists> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        credits == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const <Widget>[
                    Text(
                      'Cast',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Cast',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
        SizedBox(
          width: double.infinity,
          height: 160,
          child: credits == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: credits!.cast!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return PersonDetailPage(
                              cast: credits!.cast![index],
                              heroId: credits!.cast![index].id.toString(),
                            );
                          }));
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: Hero(
                                  tag: credits!.cast![index].id!,
                                  child: SizedBox(
                                    width: 75,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child:
                                          credits!.cast![index].profilePath ==
                                                  null
                                              ? Image.asset(
                                                  'assets/images/na_logo.png',
                                                  fit: BoxFit.cover,
                                                )
                                              : FadeInImage(
                                                  image: NetworkImage(
                                                      TMDB_BASE_IMAGE_URL +
                                                          'w500/' +
                                                          credits!.cast![index]
                                                              .profilePath!),
                                                  fit: BoxFit.cover,
                                                  placeholder: const AssetImage(
                                                      'assets/images/loading.gif'),
                                                ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    credits!.cast![index].name!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class TVImagesDisplay extends StatefulWidget {
  final String? api, title;
  const TVImagesDisplay({Key? key, this.api, this.title}) : super(key: key);

  @override
  _TVImagesDisplayState createState() => _TVImagesDisplayState();
}

class _TVImagesDisplayState extends State<TVImagesDisplay> {
  Images? tvImages;
  @override
  void initState() {
    super.initState();
    fetchImages(widget.api!).then((value) {
      setState(() {
        tvImages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    // double deviceWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        tvImages == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.title!,
                      style: const TextStyle(
                          fontSize:
                              20), /* style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                          fontSize:
                              20), /*style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: deviceHeight * 0.20,
            child: tvImages == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : tvImages!.backdrop!.isEmpty
                    ? SizedBox(
                        width: double.infinity,
                        height: deviceHeight * 0.10,
                        child: const Center(
                          child: Text(
                            'This movie doesn\'t have an image provided',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : CarouselSlider.builder(
                        options: CarouselOptions(
                          disableCenter: true,
                          viewportFraction: 0.8,
                          enlargeCenterPage: false,
                          autoPlay: true,
                        ),
                        itemBuilder:
                            (BuildContext context, int index, pageViewIndex) {
                          return Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: FadeInImage(
                                  image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                      'w500/' +
                                      tvImages!.backdrop![index].filePath!),
                                  fit: BoxFit.cover,
                                  placeholder: const AssetImage(
                                      'assets/images/loading.gif'),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: tvImages!.backdrop!.length,
                      ),
          ),
        ),
      ],
    );
  }
}

class TVVideosDisplay extends StatefulWidget {
  final String? api, title;
  const TVVideosDisplay({Key? key, this.api, this.title}) : super(key: key);

  @override
  _TVVideosDisplayState createState() => _TVVideosDisplayState();
}

class _TVVideosDisplayState extends State<TVVideosDisplay> {
  Videos? tvVideos;

  @override
  void initState() {
    super.initState();
    fetchVideos(widget.api!).then((value) {
      setState(() {
        tvVideos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    // double deviceWidth = MediaQuery.of(context).size.width;
    bool playButtonVisibility = true;
    return Column(
      children: [
        tvVideos == null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.title!,
                      style: const TextStyle(
                          fontSize:
                              20), /* style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                          fontSize:
                              20), /*style: widget.themeData!.textTheme.bodyText1*/
                    ),
                  ),
                ],
              ),
        Container(
          child: SizedBox(
            width: double.infinity,
            height: deviceHeight * 0.27,
            child: tvVideos == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : tvVideos!.result!.isEmpty
                    ? SizedBox(
                        width: double.infinity,
                        height: deviceHeight * 0.10,
                        child: const Center(
                          child:
                              Text('This movie doesn\'t have a video provided'),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: deviceHeight * 0.19,
                        child: CarouselSlider.builder(
                          options: CarouselOptions(
                            disableCenter: true,
                            viewportFraction: 0.8,
                            enlargeCenterPage: false,
                            autoPlay: true,
                          ),
                          itemBuilder:
                              (BuildContext context, int index, pageViewIndex) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  launch(YOUTUBE_BASE_URL +
                                      tvVideos!.result![index].videoLink!);
                                },
                                child: SizedBox(
                                  height: deviceHeight * 0.18,
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: deviceHeight * 0.17,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  FadeInImage(
                                                    image: NetworkImage(
                                                        YOUTUBE_THUMBNAIL_URL +
                                                            tvVideos!
                                                                .result![index]
                                                                .videoLink! +
                                                            '/hqdefault.jpg'),
                                                    fit: BoxFit.cover,
                                                    placeholder: const AssetImage(
                                                        'assets/images/loading.gif'),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        playButtonVisibility,
                                                    child: const SizedBox(
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        size: 90,
                                                      ),
                                                      height: 90,
                                                      width: 90,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          tvVideos!.result![index].name!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: tvVideos!.result!.length,
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}

class TVCastTab extends StatefulWidget {
  final String? api;
  const TVCastTab({Key? key, this.api}) : super(key: key);

  @override
  _TVCastTabState createState() => _TVCastTabState();
}

class _TVCastTabState extends State<TVCastTab>
    with AutomaticKeepAliveClientMixin<TVCastTab> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return credits == null
        ? Container(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            padding: const EdgeInsets.only(
              left: 8.0,
            ),
            color: const Color(0xFF202124),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: credits!.cast!.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return PersonDetailPage(
                          cast: credits!.cast![index],
                          heroId: credits!.cast![index].id.toString());
                    }));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 16.0, top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: credits!.cast![index].profilePath == null
                                ? Image.asset(
                                    'assets/images/na_logo.png',
                                    fit: BoxFit.cover,
                                  )
                                : FadeInImage(
                                    image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                        'w500/' +
                                        credits!.cast![index].profilePath!),
                                    fit: BoxFit.cover,
                                    placeholder: const AssetImage(
                                        'assets/images/loading.gif'),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, bottom: 8.0, right: 8.0, left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  credits!.cast![index].name!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'As : ' +
                                      credits!
                                          .cast![index].roles![0].character!,
                                ),
                                Text(
                                  credits!.cast![index].roles![0].episodeCount!
                                          .toString() +
                                      ' episodes',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  @override
  bool get wantKeepAlive => true;
}

class TVCrewTab extends StatefulWidget {
  final String? api;
  const TVCrewTab({Key? key, this.api}) : super(key: key);

  @override
  _TVCrewTabState createState() => _TVCrewTabState();
}

class _TVCrewTabState extends State<TVCrewTab>
    with AutomaticKeepAliveClientMixin<TVCrewTab> {
  Credits? credits;
  @override
  void initState() {
    super.initState();
    fetchCredits(widget.api!).then((value) {
      setState(() {
        credits = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return credits == null
        ? Container(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            padding: const EdgeInsets.only(
              left: 8.0,
            ),
            color: const Color(0xFF202124),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: credits!.crew!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 16.0, top: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: credits!.crew![index].profilePath == null
                              ? Image.asset(
                                  'assets/images/na_logo.png',
                                  fit: BoxFit.cover,
                                )
                              : FadeInImage(
                                  image: NetworkImage(TMDB_BASE_IMAGE_URL +
                                      'w500/' +
                                      credits!.crew![index].profilePath!),
                                  fit: BoxFit.cover,
                                  placeholder: const AssetImage(
                                      'assets/images/loading.gif'),
                                ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                credits!.crew![index].name!,
                                // style: themeData!.textTheme.bodyText2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Job : ' + credits!.crew![index].department!,
                                // style: themeData!.textTheme.bodyText1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }

  @override
  bool get wantKeepAlive => true;
}

class TVRecommendationsTab extends StatefulWidget {
  final String api;
  const TVRecommendationsTab({Key? key, required this.api}) : super(key: key);

  @override
  _TVRecommendationsTabState createState() => _TVRecommendationsTabState();
}

class _TVRecommendationsTabState extends State<TVRecommendationsTab>
    with AutomaticKeepAliveClientMixin {
  List<TV>? tvList;
  @override
  void initState() {
    super.initState();
    fetchTV(widget.api).then((value) {
      setState(() {
        tvList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      color: const Color(0xFF202124),
      child: tvList == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : tvList!.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'We don\'t have a recommendations for this movie :(',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: tvList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return TVDetailPage(
                            tvSeries: tvList![index],
                            heroId: '${tvList![index].id}',
                          );
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, bottom: 8.0, top: 0.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  width: 80,
                                  height: 125,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: tvList![index].posterPath == null
                                        ? Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                          )
                                        : FadeInImage(
                                            image: NetworkImage(
                                                TMDB_BASE_IMAGE_URL +
                                                    'w500/' +
                                                    tvList![index].posterPath!),
                                            fit: BoxFit.cover,
                                            placeholder: const AssetImage(
                                                'assets/images/loading.gif'),
                                          ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          tvList![index].originalName!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontFamily: 'Poppins'),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              tvList![index]
                                                  .voteAverage!
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins'),
                                            ),
                                            const Icon(Icons.star,
                                                color: Color(0xFFF57C00)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Divider(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SimilarTVTab extends StatefulWidget {
  final String api;
  const SimilarTVTab({Key? key, required this.api}) : super(key: key);

  @override
  _SimilarTVTabState createState() => _SimilarTVTabState();
}

class _SimilarTVTabState extends State<SimilarTVTab>
    with AutomaticKeepAliveClientMixin {
  List<TV>? tvList;
  @override
  void initState() {
    super.initState();
    fetchTV(widget.api).then((value) {
      setState(() {
        tvList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      color: const Color(0xFF202124),
      child: tvList == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : tvList!.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'We don\'t have a similars for this movie :(',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: tvList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return TVDetailPage(
                            tvSeries: tvList![index],
                            heroId: '${tvList![index].id}',
                          );
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, bottom: 8.0, top: 0.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 125,
                                  width: 80,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: tvList![index].posterPath == null
                                        ? Image.asset(
                                            'assets/images/na_logo.png',
                                            fit: BoxFit.cover,
                                          )
                                        : FadeInImage(
                                            image: NetworkImage(
                                                TMDB_BASE_IMAGE_URL +
                                                    'w500/' +
                                                    tvList![index].posterPath!),
                                            fit: BoxFit.cover,
                                            placeholder: const AssetImage(
                                                'assets/images/loading.gif'),
                                          ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          tvList![index].originalName!,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontFamily: 'Poppins'),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              tvList![index]
                                                  .voteAverage!
                                                  .toStringAsFixed(1),
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins'),
                                            ),
                                            const Icon(Icons.star,
                                                color: Color(0xFFF57C00)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              child: Divider(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TVGenreDisplay extends StatefulWidget {
  final String? api;
  const TVGenreDisplay({Key? key, this.api}) : super(key: key);

  @override
  _TVGenreDisplayState createState() => _TVGenreDisplayState();
}

class _TVGenreDisplayState extends State<TVGenreDisplay>
    with AutomaticKeepAliveClientMixin<TVGenreDisplay> {
  List<TVGenres>? tvGenreList;
  @override
  void initState() {
    super.initState();
    fetchTVGenre(widget.api!).then((value) {
      setState(() {
        tvGenreList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        child: SizedBox(
      height: tvGenreList == null ? 0 : 80,
      child: tvGenreList == null
          ? Container()
          : ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: tvGenreList!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TVGenreMovies(
                                    tvGenres: tvGenreList![index],
                                  )));
                    },
                    child: Chip(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 2,
                            style: BorderStyle.solid,
                            color: Color(0xFFad5700)),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      label: Text(
                        tvGenreList![index].genreName!,
                        style: const TextStyle(fontFamily: 'Poppins'),
                        // style: widget.themeData.textTheme.bodyText1,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                );
              },
            ),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}

class ParticularGenreTV extends StatefulWidget {
  final String api;
  final int genreId;
  const ParticularGenreTV({Key? key, required this.api, required this.genreId})
      : super(key: key);
  @override
  _ParticularGenreTVState createState() => _ParticularGenreTVState();
}

class _ParticularGenreTVState extends State<ParticularGenreTV> {
  List<TV>? tvList;
  final _scrollController = ScrollController();

  int pageNum = 2;
  bool isLoading = false;

  Future<String> getMoreData() async {
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoading = true;
        });

        var response = await http.get(
            Uri.parse('$TMDB_API_BASE_URL/discover/tv?api_key=$TMDB_API_KEY'
                '&language=en-US'
                '&sort_by=popularity.desc'
                '&watch_region=US'
                '&page=$pageNum'
                '&with_genres=${widget.genreId}'));
        setState(() {
          pageNum++;
          isLoading = false;
          var newlistMovies = (json.decode(response.body)['results'] as List)
              .map((i) => TV.fromJson(i))
              .toList();
          tvList!.addAll(newlistMovies);
        });
      }
    });

    return "success";
  }

  @override
  void initState() {
    super.initState();
    fetchTV(widget.api).then((value) {
      setState(() {
        tvList = value;
      });
    });
    getMoreData();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      color: const Color(0xFF202124),
      child: tvList == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : tvList!.isEmpty
              ? const Center(
                  child: Text(
                    'Oops! movies for this genre doesn\'t exist :(',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        controller: _scrollController,
                        itemCount: tvList!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TVDetailPage(
                                          tvSeries: tvList![index],
                                          heroId: '${tvList![index].id}')));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 85,
                                        height: 130,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child:
                                              tvList![index].posterPath == null
                                                  ? Image.asset(
                                                      'assets/images/na_logo.png',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : FadeInImage(
                                                      image: NetworkImage(
                                                          TMDB_BASE_IMAGE_URL +
                                                              'w500/' +
                                                              tvList![index]
                                                                  .posterPath!),
                                                      fit: BoxFit.cover,
                                                      placeholder: const AssetImage(
                                                          'assets/images/loading.gif'),
                                                    ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                tvList![index].originalName!,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                    fontFamily: 'Poppins'),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Text(
                                                    tvList![index]
                                                        .voteAverage!
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins'),
                                                  ),
                                                  const Icon(Icons.star,
                                                      color: Color(0xFFF57C00)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    child: Divider(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Visibility(
                        visible: isLoading,
                        child:
                            const Center(child: CircularProgressIndicator())),
                  ],
                ),
    );
  }
}

class TVInfoTable extends StatefulWidget {
  final String? api;
  const TVInfoTable({Key? key, this.api}) : super(key: key);

  @override
  _TVInfoTableState createState() => _TVInfoTableState();
}

class _TVInfoTableState extends State<TVInfoTable> {
  TVDetails? tvDetails;

  @override
  void initState() {
    super.initState();
    fetchTVDetails(widget.api!).then((value) {
      setState(() {
        tvDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return tvDetails == null
        ? const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              child: CircularProgressIndicator(),
            ),
          )
        : Column(
            children: [
              const Text(
                'TV series Info',
                style: TextStyle(fontSize: 25),
              ),
              Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(dataRowHeight: 40, columns: [
                      const DataColumn(
                          label: Text(
                        'Original Title',
                        style: TextStyle(overflow: TextOverflow.ellipsis),
                      )),
                      DataColumn(
                        label: Text(
                          tvDetails!.originalTitle!,
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ], rows: [
                      DataRow(cells: [
                        const DataCell(Text('Status')),
                        DataCell(Text(tvDetails!.status!.isEmpty
                            ? 'unknown'
                            : tvDetails!.status!)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Runtime')),
                        DataCell(Text(tvDetails!.runtime!.isEmpty
                            ? '-'
                            : tvDetails!.runtime![0] == 0
                                ? 'N/A'
                                : '${tvDetails!.runtime![0]} mins')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Total seasons')),
                        DataCell(Text(tvDetails!.numberOfSeasons! == 0
                            ? '-'
                            : '${tvDetails!.numberOfSeasons!}')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Total episodes')),
                        DataCell(Text(tvDetails!.numberOfEpisodes! == 0
                            ? '-'
                            : '${tvDetails!.numberOfEpisodes!}')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Tagline')),
                        DataCell(
                          Text(
                            tvDetails!.tagline!.isEmpty
                                ? '-'
                                : tvDetails!.tagline!,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Production company')),
                        DataCell(
                          tvDetails!.productionCompanies!.isEmpty
                              ? const Text('-')
                              : Text(tvDetails!.productionCompanies![0].name!),
                        ),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Production country')),
                        DataCell(
                          tvDetails!.productionCompanies!.isEmpty
                              ? const Text('-')
                              : Text(tvDetails!.productionCountries![0].name!),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ),
            ],
          );
  }
}
