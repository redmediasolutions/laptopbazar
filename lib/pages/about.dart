// ignore_for_file: deprecated_member_use

import 'package:electralap/components/footer.dart';
import 'package:electralap/components/header.dart';
import 'package:electralap/services/nav.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class About extends StatelessComponent {
  const About({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'page', [
      const AppHeader(),
      main_([
        section(classes: 'about-main', [
          div(classes: 'container', [
            div(classes: 'about-hero', [
              div(classes: 'about-hero-copy', [
                span(classes: 'chip', [text('India First Refurbished Platform')]),
                h1([text('About ELECTRALAP')]),
                p([
                  text(
                      'ELECTRALAP helps students, professionals, and businesses across India buy premium refurbished laptops with confidence. We blend strong quality standards, fair pricing, and responsive support to make technology more accessible.')
                ]),
                div(classes: 'about-hero-actions', [
                  Link(to: NavPaths.products, classes: 'btn btn-primary', child: text('Explore Products')),
                  Link(to: NavPaths.contact, classes: 'btn btn-ghost', child: text('Talk to Us')),
                ]),
              ]),
              div(classes: 'about-hero-card', [
                h3([text('What Makes Us Different')]),
                ul([
                  li([text('40+ quality checks on every device')]),
                  li([text('Pan-India delivery and support coverage')]),
                  li([text('GST billing for startups and enterprises')]),
                  li([text('Trusted by growing teams and creators')]),
                ]),
              ]),
            ]),
            div(classes: 'about-stats-grid', [
              statTile('50,000+', 'Happy Customers'),
              statTile('40+', 'Quality Checkpoints'),
              statTile('120+', 'Cities Delivered'),
              statTile('4.9/5', 'Average Rating'),
            ]),
            div(classes: 'about-values-grid', [
              aboutValue(
                'verified',
                'Certified Quality',
                'Every laptop is thoroughly tested for performance, battery health, and hardware reliability before listing.',
              ),
              aboutValue(
                'payments',
                'Honest Pricing',
                'Transparent rates with no hidden surprises, making premium devices practical for Indian buyers.',
              ),
              aboutValue(
                'support_agent',
                'Real Support',
                'Our team helps with setup, warranty guidance, and post-purchase questions with fast response.',
              ),
            ]),
            div(classes: 'about-process-card', [
              h2([text('How ELECTRALAP Works')]),
              div(classes: 'about-process-grid', [
                processStep('1', 'Source', 'We source reliable premium devices from verified channels.'),
                processStep('2', 'Refurbish', 'Engineers inspect, clean, and optimize each machine for long-term use.'),
                processStep('3', 'Certify', 'Devices pass our quality checklist before they are approved for sale.'),
                processStep('4', 'Deliver', 'Fast doorstep delivery across India with tracking and support.'),
              ]),
            ]),
            div(classes: 'about-cta', [
              h2([text('Built for India. Backed by Trust.')]),
              p([text('Whether you are buying for studies, work, or your growing business, ELECTRALAP is built to deliver dependable value.')]),
              Link(to: NavPaths.contact, classes: 'btn btn-primary', child: text('Contact Us')),
            ]),
          ]),
        ]),
      ]),
      const AppFooter(),
    ]);
  }
}

Component statTile(String value, String label) {
  return div(classes: 'about-stat-tile', [
    h3([text(value)]),
    p([text(label)]),
  ]);
}

Component aboutValue(String icon, String title, String description) {
  return div(classes: 'about-value-card', [
    div(classes: 'about-value-icon', [
      span(classes: 'material-symbols-outlined', [text(icon)]),
    ]),
    h3([text(title)]),
    p([text(description)]),
  ]);
}

Component processStep(String number, String title, String description) {
  return div(classes: 'about-step', [
    span(classes: 'about-step-no', [text(number)]),
    h3([text(title)]),
    p([text(description)]),
  ]);
}
