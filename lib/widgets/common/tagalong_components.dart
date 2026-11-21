import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';

/// Building blocks shared by the redesigned screens. Each one matches a
/// component on the Figma "Components" page.

// -----------------------------------------------------------------------------
// Tag
// -----------------------------------------------------------------------------

/// Colour of a [TagAlongTag]. Peach = to campus, sky = from campus, mint =
/// success, butter = warning, rose = error/cancelled, lavender = role.
enum TagTone { peach, sky, mint, lavender, butter, rose, neutral }

class TagAlongTag extends StatelessWidget {
  const TagAlongTag({Key? key, required this.label, required this.tone}) : super(key: key);

  /// A direction tag for a ride.
  factory TagAlongTag.direction(bool toCampus, {Key? key}) => TagAlongTag(
      key: key, label: toCampus ? 'To campus' : 'From campus', tone: toCampus ? TagTone.peach : TagTone.sky);

  final String label;
  final TagTone tone;

  static (Color, Color) colorsFor(TagTone tone) {
    switch (tone) {
      case TagTone.peach:
        return (TagAlongColors.toCampus, TagAlongColors.toCampusInk);
      case TagTone.sky:
        return (TagAlongColors.fromCampus, TagAlongColors.fromCampusInk);
      case TagTone.mint:
        return (TagAlongColors.success, TagAlongColors.successInk);
      case TagTone.lavender:
        return (TagAlongColors.brandSoft, TagAlongColors.textBrand);
      case TagTone.butter:
        return (TagAlongColors.warning, TagAlongColors.warningInk);
      case TagTone.rose:
        return (TagAlongColors.error, TagAlongColors.errorInk);
      case TagTone.neutral:
        return (TagAlongColors.canvas, TagAlongColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = colorsFor(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s2, vertical: TagAlongSpace.s1),
      decoration: BoxDecoration(color: bg, borderRadius: TagAlongRadius.pill),
      child: Text(label.toUpperCase(), style: TagAlongText.overline.copyWith(color: fg)),
    );
  }
}

// -----------------------------------------------------------------------------
// Avatar
// -----------------------------------------------------------------------------

/// A profile photo, falling back to initials on a pastel tone.
class TagAlongAvatar extends StatelessWidget {
  const TagAlongAvatar({
    Key? key,
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.color,
  }) : super(key: key);

  final String name;
  final String? imageUrl;
  final double size;

  /// Background behind the initials. Picked from [name] when null, so the
  /// same person always gets the same colour.
  final Color? color;

  static const _tones = [
    TagAlongColors.brandSoft,
    TagAlongColors.toCampus,
    TagAlongColors.success,
    TagAlongColors.fromCampus,
  ];

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = color ?? _tones[name.hashCode.abs() % _tones.length];
    final initials = Center(
      child: Text(
        _initials,
        style: TagAlongText.labelMedium.copyWith(fontSize: size * 0.33),
      ),
    );
    final url = imageUrl;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? initials
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => initials,
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// Surfaces
// -----------------------------------------------------------------------------

/// White rounded card with the low ink shadow.
class TagAlongCard extends StatelessWidget {
  const TagAlongCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(TagAlongSpace.s4),
    this.radius = TagAlongRadius.lg,
    this.color = TagAlongColors.surface,
    this.onTap,
    this.shadow = true,
    this.border,
  }) : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final VoidCallback? onTap;
  final bool shadow;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: shadow ? TagAlongShadows.level1 : null,
      ),
      child: Material(
        color: color,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: border == null ? null : BoxDecoration(border: border, borderRadius: shape),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Round icon button: white with a shadow, or a flat pastel fill.
class TagAlongIconButton extends StatelessWidget {
  const TagAlongIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color = TagAlongColors.surface,
    this.size = 44,
    this.tooltip,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: color == TagAlongColors.surface ? TagAlongShadows.level1 : null,
      ),
      child: Material(
        color: color,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: 20, color: TagAlongColors.textPrimary),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

// -----------------------------------------------------------------------------
// Headers
// -----------------------------------------------------------------------------

/// Large page title (Display/Medium) with an optional line under it and an
/// optional trailing action. Replaces the solid app bar on the main tabs.
class TagAlongPageHeader extends StatelessWidget {
  const TagAlongPageHeader({Key? key, required this.title, this.eyebrow, this.subtitle, this.trailing})
      : super(key: key);

  final String title;

  /// Small line above the title ("Hey, Jordan").
  final String? eyebrow;

  /// Small line below the title.
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(eyebrow!, style: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary)),
                ),
              Text(title, style: TagAlongText.displayMedium),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!, style: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary)),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Top bar for pushed screens: round back button, centred title, optional
/// trailing button.
class TagAlongTopBar extends StatelessWidget implements PreferredSizeWidget {
  const TagAlongTopBar({Key? key, required this.title, this.trailing, this.onBack}) : super(key: key);

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return SafeArea(
      bottom: false,
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(TagAlongSpace.gutter, TagAlongSpace.s3, TagAlongSpace.gutter, TagAlongSpace.s2),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: canPop || onBack != null
                  ? TagAlongIconButton(
                      icon: Icons.chevron_left_rounded,
                      tooltip: 'Back',
                      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    )
                  : null,
            ),
            Expanded(child: Text(title, textAlign: TextAlign.center, style: TagAlongText.titleSmall)),
            SizedBox(width: 44, child: trailing),
          ],
        ),
      ),
    );
  }
}

/// Section title with a muted count and an optional action on the right.
class TagAlongSectionHeader extends StatelessWidget {
  const TagAlongSectionHeader({Key? key, required this.title, this.count, this.action, this.onAction})
      : super(key: key);

  final String title;
  final String? count;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: TagAlongText.titleMedium),
        if (count != null) ...[
          const SizedBox(width: TagAlongSpace.s2),
          Text(count!, style: TagAlongText.labelMedium.copyWith(color: TagAlongColors.textTertiary)),
        ],
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: TagAlongSpace.s1),
              child: Text(action!, style: TagAlongText.labelMedium.copyWith(color: TagAlongColors.textBrand)),
            ),
          ),
      ],
    );
  }
}

/// Small capitalised label above a group ("ACCOUNT", "HELP").
class TagAlongOverline extends StatelessWidget {
  const TagAlongOverline(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: TagAlongText.overline.copyWith(color: TagAlongColors.textTertiary));
  }
}

// -----------------------------------------------------------------------------
// Controls
// -----------------------------------------------------------------------------

/// Pill segmented control on a lavender track; the selected segment is white.
class TagAlongSegmented extends StatelessWidget {
  const TagAlongSegmented({Key? key, required this.labels, required this.selected, required this.onChanged})
      : super(key: key);

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(TagAlongSpace.s1),
      decoration: BoxDecoration(color: TagAlongColors.subtle, borderRadius: TagAlongRadius.pill),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                selected: i == selected,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selected ? TagAlongColors.surface : Colors.transparent,
                      borderRadius: TagAlongRadius.pill,
                      boxShadow: i == selected ? TagAlongShadows.level1 : null,
                    ),
                    child: Text(
                      labels[i],
                      style: TagAlongText.labelMedium.copyWith(
                        color: i == selected ? TagAlongColors.textPrimary : TagAlongColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Quick filter chip: white outline, ink when selected.
class TagAlongFilterChip extends StatelessWidget {
  const TagAlongFilterChip({Key? key, required this.label, required this.selected, required this.onTap, this.icon})
      : super(key: key);

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? TagAlongColors.textOnInverse : TagAlongColors.textPrimary;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? TagAlongColors.inverse : TagAlongColors.surface,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? TagAlongColors.inverse : TagAlongColors.border, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(label, style: TagAlongText.labelMedium.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Ride pieces
// -----------------------------------------------------------------------------

/// Calendar block: month overline over a big day number, on a tinted square.
class TagAlongDateBlock extends StatelessWidget {
  const TagAlongDateBlock({Key? key, required this.date, required this.color}) : super(key: key);

  final DateTime date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 56,
      decoration: BoxDecoration(color: color, borderRadius: TagAlongRadius.mdAll),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DateFormat('MMM').format(date).toUpperCase(),
              style: TagAlongText.overline.copyWith(color: TagAlongColors.textSecondary)),
          Text(DateFormat('dd').format(date), style: TagAlongText.price),
        ],
      ),
    );
  }
}

/// One stop on a [TagAlongRouteTimeline].
class RouteStop {
  const RouteStop({required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;
}

/// Pickup (ringed dot) joined by a short line to dropoff (filled dot).
class TagAlongRouteTimeline extends StatelessWidget {
  const TagAlongRouteTimeline({
    Key? key,
    required this.pickup,
    required this.dropoff,
    this.titleStyle,
    this.connectorHeight = 14,
  }) : super(key: key);

  final RouteStop pickup;
  final RouteStop dropoff;
  final TextStyle? titleStyle;
  final double connectorHeight;

  Widget _dot(bool ringed) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ringed ? TagAlongColors.surface : TagAlongColors.textPrimary,
          border: ringed ? Border.all(color: TagAlongColors.textPrimary, width: 2.5) : null,
        ),
      );

  Widget _stop(RouteStop stop, bool ringed) {
    return Row(
      children: [
        _dot(ringed),
        const SizedBox(width: TagAlongSpace.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stop.title,
                  style: titleStyle ?? TagAlongText.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (stop.subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(stop.subtitle!,
                      style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
            ],
          ),
        ),
        if (stop.trailing != null) stop.trailing!,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stop(pickup, true),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Container(
            width: 2,
            height: connectorHeight,
            color: TagAlongColors.textTertiary.withOpacity(0.5),
          ),
        ),
        _stop(dropoff, false),
      ],
    );
  }
}

/// Filled/hollow dots showing how many seats are booked out of the total.
class TagAlongSeatDots extends StatelessWidget {
  const TagAlongSeatDots({Key? key, required this.total, required this.taken}) : super(key: key);

  final int total;
  final int taken;

  @override
  Widget build(BuildContext context) {
    // Keep the row a sensible width for big vans.
    final shown = total.clamp(0, 6);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < shown; i++)
          Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : TagAlongSpace.s1),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < taken ? TagAlongColors.textPrimary : null,
                border: i < taken ? null : Border.all(color: TagAlongColors.textTertiary, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

/// Small pill with an icon and a fact ("Silver Subaru", "2 bags each").
class TagAlongFactPill extends StatelessWidget {
  const TagAlongFactPill({Key? key, required this.icon, required this.label, this.onTap}) : super(key: key);

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TagAlongColors.canvas,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: TagAlongSpace.s2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: TagAlongColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label, style: TagAlongText.labelMedium.copyWith(color: TagAlongColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A label/amount line in a receipt.
class TagAlongReceiptRow extends StatelessWidget {
  const TagAlongReceiptRow({
    Key? key,
    required this.label,
    required this.value,
    this.emphasis = false,
    this.onInfo,
    this.valueColor,
  }) : super(key: key);

  final String label;
  final String value;

  /// The total line: bolder label, price-style value.
  final bool emphasis;

  /// Shows an info button after the label when set.
  final VoidCallback? onInfo;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: emphasis
              ? TagAlongText.titleSmall
              : TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary),
        ),
        if (onInfo != null)
          IconButton(
            onPressed: onInfo,
            tooltip: 'About $label',
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.only(left: 6),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.info_outline_rounded, size: 16, color: TagAlongColors.textTertiary),
          ),
        const Spacer(),
        Text(
          value,
          style: (emphasis ? TagAlongText.price : TagAlongText.labelMedium).copyWith(color: valueColor),
        ),
      ],
    );
  }
}

/// Bottom bar pinned under a scrolling screen: rounded top, floating shadow.
class TagAlongStickyBar extends StatelessWidget {
  const TagAlongStickyBar({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TagAlongColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(TagAlongRadius.xl)),
        boxShadow: TagAlongShadows.floating,
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: TagAlongSpace.s4),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(TagAlongSpace.gutter, TagAlongSpace.s4, TagAlongSpace.gutter, 0),
          child: child,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Settings
// -----------------------------------------------------------------------------

/// One row in a [TagAlongSettingsGroup]: pastel icon tile, title, optional
/// subtitle, chevron.
class TagAlongSettingsRow extends StatelessWidget {
  const TagAlongSettingsRow({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.tileColor = TagAlongColors.subtle,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color tileColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s4, vertical: TagAlongSpace.s3),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: tileColor, borderRadius: TagAlongRadius.mdAll),
              child: Icon(icon, size: 20, color: TagAlongColors.textPrimary),
            ),
            const SizedBox(width: TagAlongSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TagAlongText.titleSmall),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child:
                          Text(subtitle!, style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: TagAlongColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// White rounded list of [TagAlongSettingsRow]s with inset dividers, under an
/// overline title.
class TagAlongSettingsGroup extends StatelessWidget {
  const TagAlongSettingsGroup({Key? key, required this.title, required this.rows}) : super(key: key);

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TagAlongOverline(title),
        const SizedBox(height: TagAlongSpace.s2),
        TagAlongCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i < rows.length - 1) const Padding(padding: EdgeInsets.only(left: 68), child: Divider(height: 1)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Bottom navigation
// -----------------------------------------------------------------------------

/// A tab in [TagAlongBottomNav].
class TagAlongNavItem {
  const TagAlongNavItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

/// Floating ink pill tab bar. The active tab expands into a lavender pill with
/// its label; the peach + is the "Offer a ride" action, not a tab.
class TagAlongBottomNav extends StatelessWidget {
  const TagAlongBottomNav({
    Key? key,
    required this.items,
    required this.selected,
    required this.onSelected,
    required this.onOffer,
    this.offerAfter = 0,
  }) : super(key: key);

  final List<TagAlongNavItem> items;
  final int selected;
  final ValueChanged<int> onSelected;
  final VoidCallback onOffer;

  /// Index of the tab the + button follows.
  final int offerAfter;

  /// Height the nav takes up above the safe area, so scrolling content can pad
  /// its bottom and not hide behind it.
  static const double height = 68 + TagAlongSpace.s4;

  Widget _tab(int i) {
    final item = items[i];
    final active = i == selected;
    return Semantics(
      selected: active,
      button: true,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelected(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
              horizontal: active ? TagAlongSpace.s4 : TagAlongSpace.s3, vertical: TagAlongSpace.s3),
          decoration: BoxDecoration(
            color: active ? TagAlongColors.brandSoft : Colors.transparent,
            borderRadius: TagAlongRadius.pill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon,
                  size: active ? 20 : 22, color: active ? TagAlongColors.textPrimary : TagAlongColors.textOnInverse),
              if (active) ...[
                const SizedBox(width: TagAlongSpace.s2),
                Text(item.label, style: TagAlongText.labelMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      children.add(_tab(i));
      if (i == offerAfter) {
        children.add(
          Semantics(
            button: true,
            label: 'Offer a ride',
            child: Material(
              color: TagAlongColors.toCampus,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onOffer,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.add_rounded, size: 24, color: TagAlongColors.textPrimary),
                ),
              ),
            ),
          ),
        );
      }
    }

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: TagAlongSpace.s2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(TagAlongSpace.s4, 0, TagAlongSpace.s4, TagAlongSpace.s2),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s3),
          decoration: BoxDecoration(
            color: TagAlongColors.inverse,
            borderRadius: TagAlongRadius.pill,
            boxShadow: TagAlongShadows.floating,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: children),
        ),
      ),
    );
  }
}
