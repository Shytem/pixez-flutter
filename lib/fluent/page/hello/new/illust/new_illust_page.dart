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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pixez/fluent/component/sort_group.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/lighting/lighting_store.dart';
import 'package:pixez/main.dart';
import 'package:pixez/network/api_client.dart';

import '../../../../../lighting/lighting_page.dart';

class NewIllustPage extends StatefulWidget {
  final String restrict;

  const NewIllustPage({Key? key, this.restrict = "all"}) : super(key: key);

  @override
  _NewIllustPageState createState() => _NewIllustPageState();
}

class _NewIllustPageState extends State<NewIllustPage>
    with AutomaticKeepAliveClientMixin {
  late ApiForceSource futureGet;
  late StreamSubscription<String> subscription;
  late ScrollController _scrollController;
  // When true, hide AI works. Defaults to showing AI (button active).
  bool _hideAI = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    futureGet = ApiForceSource(
        futureGet: (e) => apiClient.getFollowIllusts(widget.restrict, force: e),
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
    super.build(context);
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
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SortGroup(
              onChange: (index) {
                if (index == 0)
                  setState(() {
                    futureGet = ApiForceSource(
                        futureGet: (e) =>
                            apiClient.getFollowIllusts('all', force: e),
                        glanceKey: "follow_illust");
                  });
                if (index == 1)
                  setState(() {
                    futureGet = ApiForceSource(
                        futureGet: (e) =>
                            apiClient.getFollowIllusts('public', force: e),
                        glanceKey: "follow_illust");
                  });
                if (index == 2)
                  setState(() {
                    futureGet = ApiForceSource(
                        futureGet: (e) =>
                            apiClient.getFollowIllusts('private', force: e),
                        glanceKey: "follow_illust");
                  });
              },
              children: [
                I18n.of(context).all,
                I18n.of(context).public,
                I18n.of(context).private
              ],
            ),
            const SizedBox(width: 8),
            ToggleSwitch(
              // Active means AI is shown; checked reflects show state.
              checked: !_hideAI,
              onChanged: (v) => setState(() => _hideAI = !v),
              content: Text('AI'),
            ),
          ],
        ),
          ),
        )
      ],
    );
  }

  Container buildContainer(BuildContext context) {
    FlyoutController controller = FlyoutController();
    return Container(
      child: Align(
        alignment: Alignment.centerRight,
        child: FlyoutTarget(
          controller: controller,
          child: IconButton(
            icon: Icon(FluentIcons.list),
            onPressed: () => controller.showFlyout(
              builder: (context) => MenuFlyout(
                items: [
                  MenuFlyoutItem(
                    text: Text(I18n.of(context).all),
                    onPressed: () {
                      setState(() {
                        futureGet = ApiForceSource(
                          futureGet: (e) => apiClient.getFollowIllusts(
                            'all',
                            force: e,
                          ),
                          glanceKey: "follow_illust",
                        );
                      });
                    },
                  ),
                  MenuFlyoutItem(
                    text: Text(I18n.of(context).public),
                    onPressed: () {
                      setState(() {
                        futureGet = ApiForceSource(
                          futureGet: (e) => apiClient.getFollowIllusts(
                            'public',
                            force: e,
                          ),
                          glanceKey: "follow_illust",
                        );
                      });
                    },
                  ),
                  MenuFlyoutItem(
                    text: Text(I18n.of(context).private),
                    onPressed: () {
                      setState(() {
                        futureGet = ApiForceSource(
                          futureGet: (e) => apiClient.getFollowIllusts(
                            'private',
                            force: e,
                          ),
                          glanceKey: "follow_illust",
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
