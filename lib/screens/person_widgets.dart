import 'package:cinemax/constants/api_constants.dart';
import 'package:cinemax/modals/function.dart';
import 'package:cinemax/modals/images.dart';
import 'package:cinemax/modals/movie.dart';
import 'package:cinemax/modals/person.dart';
import 'package:cinemax/modals/social_icons_icons.dart';
import 'package:cinemax/modals/tv.dart';
import 'package:cinemax/screens/movie_detail.dart';
import 'package:cinemax/screens/movie_widgets.dart';
import 'package:cinemax/screens/cast_detail.dart';
import 'package:cinemax/screens/tv_detail.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';

class PersonImagesDisplay extends StatefulWidget {
  const PersonImagesDisplay({
    Key? key,
    required this.api,
    required this.title,
  }) : super(key: key);

  final String api;
  final String title;

  @override
  State<PersonImagesDisplay> createState() => _PersonImagesDisplayState();
}

class _PersonImagesDisplayState extends State<PersonImagesDisplay>
    with AutomaticKeepAliveClientMixin {
  PersonImages? personImages;
  @override
  void initState() {
    super.initState();
    fetchPersonImages(widget.api).then((value) {
      setState(() {
        personImages = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.title,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 150,
            child: personImages == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : personImages!.profile!.isEmpty
                    ? const Center(
                        child: Text('No images available for this person'),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: personImages!.profile!.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 0.0, 15.0, 8.0),
                                  child: SizedBox(
                                    width: 100,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 6,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: FadeInImage(
                                              image: NetworkImage(
                                                  TMDB_BASE_IMAGE_URL +
                                                      'w500/' +
                                                      personImages!
                                                          .profile![index]
                                                          .filePath!),
                                              fit: BoxFit.cover,
                                              placeholder: const AssetImage(
                                                  'assets/images/loading.gif'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PersonMovieList extends StatefulWidget {
  final String api;
  const PersonMovieList({Key? key, required this.api}) : super(key: key);

  @override
  _PersonMovieListState createState() => _PersonMovieListState();
}

class _PersonMovieListState extends State<PersonMovieList>
    with AutomaticKeepAliveClientMixin<PersonMovieList> {
  List<Movie>? personMoviesList;
  @override
  void initState() {
    super.initState();
    fetchPersonMovies(widget.api).then((value) {
      setState(() {
        personMoviesList = value;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return personMoviesList == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      '${personMoviesList!.length} movies',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: personMoviesList!.isEmpty
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, bottom: 10.0, top: 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 150,
                                    childAspectRatio: 0.48,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                  ),
                                  itemCount: personMoviesList!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return MovieDetailPage(
                                              movie: personMoviesList![index],
                                              heroId:
                                                  '${personMoviesList![index].id}');
                                        }));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 6,
                                              child: Hero(
                                                tag:
                                                    '${personMoviesList![index].id}',
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child:
                                                      personMoviesList![index]
                                                                  .posterPath ==
                                                              null
                                                          ? Image.asset(
                                                              'assets/images/na_logo.png',
                                                              fit: BoxFit.cover,
                                                            )
                                                          : FadeInImage(
                                                              image: NetworkImage(
                                                                  TMDB_BASE_IMAGE_URL +
                                                                      'w500/' +
                                                                      personMoviesList![
                                                                              index]
                                                                          .posterPath!),
                                                              fit: BoxFit.cover,
                                                              placeholder:
                                                                  const AssetImage(
                                                                      'assets/images/loading.gif'),
                                                            ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                  personMoviesList![index]
                                                      .originalTitle!,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          );
  }
}

class PersonTVList extends StatefulWidget {
  final String api;
  const PersonTVList({Key? key, required this.api}) : super(key: key);

  @override
  _PersonTVListState createState() => _PersonTVListState();
}

class _PersonTVListState extends State<PersonTVList>
    with AutomaticKeepAliveClientMixin<PersonTVList> {
  List<TV>? personTVList;
  @override
  void initState() {
    super.initState();
    fetchPersonTV(widget.api).then((value) {
      setState(() {
        personTVList = value;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return personTVList == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      '${personTVList!.length} tv shows',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: personTVList!.isEmpty
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, bottom: 10.0, top: 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 150,
                                    childAspectRatio: 0.48,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                  ),
                                  itemCount: personTVList!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return TVDetailPage(
                                              tvSeries: personTVList![index],
                                              heroId:
                                                  '${personTVList![index].id}');
                                        }));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 6,
                                              child: Hero(
                                                tag:
                                                    '${personTVList![index].id}',
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: personTVList![index]
                                                              .posterPath ==
                                                          null
                                                      ? Image.asset(
                                                          'assets/images/na_logo.png',
                                                          fit: BoxFit.cover,
                                                        )
                                                      : FadeInImage(
                                                          image: NetworkImage(
                                                              TMDB_BASE_IMAGE_URL +
                                                                  'w500/' +
                                                                  personTVList![
                                                                          index]
                                                                      .posterPath!),
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              const AssetImage(
                                                                  'assets/images/loading.gif'),
                                                        ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                  personTVList![index]
                                                      .originalName!,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          );
  }
}

class PersonAboutWidget extends StatefulWidget {
  final String api;
  const PersonAboutWidget({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  State<PersonAboutWidget> createState() => _PersonAboutWidgetState();
}

class _PersonAboutWidgetState extends State<PersonAboutWidget>
    with AutomaticKeepAliveClientMixin {
  PersonDetails? personDetails;

  @override
  void initState() {
    super.initState();
    fetchPersonDetails(widget.api).then((value) {
      setState(() {
        personDetails = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return personDetails == null
        ? const CircularProgressIndicator()
        : Column(
            children: [
              Row(
                children: <Widget>[
                  const Text(
                    'Age',
                    style: TextStyle(color: Colors.white54),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(personDetails?.birthday != null
                        ? '${DateTime.parse(DateTime.now().toString()).year.toInt() - DateTime.parse(personDetails!.birthday!.toString()).year - 1}'
                        : '-'),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  const Text(
                    'Born on',
                    style: TextStyle(color: Colors.white54),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: Text(personDetails?.birthday != null
                        ? '${DateTime.parse(personDetails!.birthday!).day} ${DateFormat.MMMM().format(DateTime.parse(personDetails!.birthday!))} ${DateTime.parse(personDetails!.birthday!.toString()).year}'
                        : '-'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: const Text(
                      'From',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 5.0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            personDetails?.birthPlace != null
                                ? personDetails!.birthPlace!
                                : '-',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Biography',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  ReadMoreText(
                    personDetails?.biography != ""
                        ? personDetails!.biography!
                        : 'We don\'t have a biography for this person',
                    trimLines: 4,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    colorClickableText: const Color(0xFFF57C00),
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Show more',
                    trimExpandedText: 'Show less',
                    lessStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFF57C00),
                        fontWeight: FontWeight.bold),
                    moreStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFF57C00),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          );
  }

  @override
  bool get wantKeepAlive => true;
}

class PersonSocialLinks extends StatefulWidget {
  final String? api;
  const PersonSocialLinks({
    Key? key,
    this.api,
  }) : super(key: key);

  @override
  _PersonSocialLinksState createState() => _PersonSocialLinksState();
}

class _PersonSocialLinksState extends State<PersonSocialLinks> {
  ExternalLinks? externalLinks;
  bool? isAllNull;
  @override
  void initState() {
    super.initState();
    fetchSocialLinks(widget.api!).then((value) {
      setState(() {
        externalLinks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Social media links',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: externalLinks == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : externalLinks?.facebookUsername == null &&
                          externalLinks?.instagramUsername == null &&
                          externalLinks?.twitterUsername == null &&
                          externalLinks?.imdbId == null
                      ? Center(
                          child: Text(
                            'This person doesn\'t have social media links provided :(',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            SocialIconWidget(
                              isNull: externalLinks?.facebookUsername == null,
                              url: externalLinks?.facebookUsername == null
                                  ? ''
                                  : FACEBOOK_BASE_URL +
                                      externalLinks!.facebookUsername!,
                              icon: const Icon(
                                SocialIcons.facebook_f,
                                color: Color(0xFFF57C00),
                              ),
                            ),
                            SocialIconWidget(
                              isNull: externalLinks?.instagramUsername == null,
                              url: externalLinks?.instagramUsername == null
                                  ? ''
                                  : INSTAGRAM_BASE_URL +
                                      externalLinks!.instagramUsername!,
                              icon: const Icon(
                                SocialIcons.instagram,
                                color: Color(0xFFF57C00),
                              ),
                            ),
                            SocialIconWidget(
                              isNull: externalLinks?.twitterUsername == null,
                              url: externalLinks?.twitterUsername == null
                                  ? ''
                                  : TWITTER_BASE_URL +
                                      externalLinks!.twitterUsername!,
                              icon: const Icon(
                                SocialIcons.twitter,
                                color: Color(0xFFF57C00),
                              ),
                            ),
                            SocialIconWidget(
                              isNull: externalLinks?.imdbId == null,
                              url: externalLinks?.imdbId == null
                                  ? ''
                                  : IMDB_BASE_URL + externalLinks!.imdbId!,
                              icon: const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.imdb,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
