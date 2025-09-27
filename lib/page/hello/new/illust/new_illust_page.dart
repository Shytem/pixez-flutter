/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pixez/component/sort_group.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_page.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';

class NewIllustPage extends StatefulWidget {
  final String restrict;

  const NewIllustPage({Key? key, this.restrict = "all"}) : super(key: key);

  @override
  _NewIllustPageState createState() => _NewIllustPageState();
}

class _NewIllustPageState extends State<NewIllustPage> {
  late ApiForceSource futureGet;
  late StreamSubscription<String> subscription;
  late ScrollController _scrollController;
  // When true, hide AI works. Defaults to showing AI (button active).
  bool _hideAI = false;
  late String _restrict;
  // R-18 filter mode: 0 allow, 1 hide, 2 only. Default allow (show).
  int _r18Mode = 0;

  @override
  void initState() {
    _scrollController = ScrollController();
    _restrict = widget.restrict;
    futureGet = ApiForceSource(
        futureGet: (e) => apiClient.getFollowIllusts(_restrict, force: e),
        glanceKey: "follow_illust");
    super.initState();
    subscription = topStore.topStream.listen((event) {
      if (event == "301") {
        _scrollController.position.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LightingList(
          source: futureGet,
          scrollController: _scrollController,
          header: Container(
            height: 45.0,
          ),
          portal: "new",
          ai: _hideAI,
          r18Mode: _r18Mode,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: ActionChip(
              avatar: Icon(Icons.tune, size: 18),
              label: Text('Filters'),
              onPressed: _showFilterBottomSheet,
              backgroundColor: Theme.of(context).cardColor,
              elevation: 2.0,
            ),
          ),
        )
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              String localRestrict = _restrict;
              bool localShowAI = !_hideAI;
              int localR18 = _r18Mode;
              void applyRestrict(String restrict) {
                setModalState(() => localRestrict = restrict);
                setState(() {
                  _restrict = restrict;
                  futureGet = ApiForceSource(
                    futureGet: (e) => apiClient.getFollowIllusts(_restrict, force: e),
                    glanceKey: "follow_illust",
                  );
                });
              }
              void applyShowAI(bool v) {
                setModalState(() => localShowAI = v);
                setState(() => _hideAI = !v);
              }
              void applyR18(int mode) {
                setModalState(() => localR18 = mode);
                setState(() => _r18Mode = mode);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 12,
                  ),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(I18n.of(context).all),
                      trailing: localRestrict == 'all' ? const Icon(Icons.check) : null,
                      selected: localRestrict == 'all',
                      onTap: () => applyRestrict('all'),
                    ),
                    ListTile(
                      title: Text(I18n.of(context).public),
                      trailing: localRestrict == 'public' ? const Icon(Icons.check) : null,
                      selected: localRestrict == 'public',
                      onTap: () => applyRestrict('public'),
                    ),
                    ListTile(
                      title: Text(I18n.of(context).private),
                      trailing: localRestrict == 'private' ? const Icon(Icons.check) : null,
                      selected: localRestrict == 'private',
                      onTap: () => applyRestrict('private'),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('AI'),
                      value: localShowAI,
                      onChanged: applyShowAI,
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('R-18 Allow'),
                      trailing: localR18 == 0 ? const Icon(Icons.check) : null,
                      selected: localR18 == 0,
                      onTap: () => applyR18(0),
                    ),
                    ListTile(
                      title: const Text('R-18 Hide'),
                      trailing: localR18 == 1 ? const Icon(Icons.check) : null,
                      selected: localR18 == 1,
                      onTap: () => applyR18(1),
                    ),
                    ListTile(
                      title: const Text('R-18 Only'),
                      trailing: localR18 == 2 ? const Icon(Icons.check) : null,
                      selected: localR18 == 2,
                      onTap: () => applyR18(2),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(I18n.of(context).ok),
                      ),
                    ),
                  ],
                ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Container buildContainer(BuildContext context) {
    return Container(
        child: Align(
      alignment: Alignment.centerRight,
      child: IconButton(
          icon: Icon(Icons.list),
          onPressed: () {
            showModalBottomSheet(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                context: context,
                builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Text(I18n.of(context).all),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                futureGet = ApiForceSource(
                                    futureGet: (e) => apiClient
                                        .getFollowIllusts('all', force: e),
                                    glanceKey: "follow_illust");
                              });
                            },
                          ),
                          ListTile(
                            title: Text(I18n.of(context).public),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                futureGet = ApiForceSource(
                                    futureGet: (e) => apiClient
                                        .getFollowIllusts('public', force: e),
                                    glanceKey: "follow_illust");
                              });
                            },
                          ),
                          ListTile(
                            title: Text(I18n.of(context).private),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                futureGet = ApiForceSource(
                                    futureGet: (e) => apiClient
                                        .getFollowIllusts('private', force: e),
                                    glanceKey: "follow_illust");
                              });
                            },
                          ),
                        ],
                      ),
                    ));
          }),
    ));
  }
}
