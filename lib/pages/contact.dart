 // ignore_for_file: deprecated_member_use

import 'package:electralap/components/footer.dart';
import 'package:electralap/components/header.dart';
import 'package:electralap/services/nav.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class ContactPage extends StatelessComponent {
  const ContactPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'page', [
      const AppHeader(),
      main_([
        section(classes: 'contact-main', [
          div(classes: 'container', [
            h1(classes: 'contact-title', [text('Contact ELECTRALAP')]),
            p(classes: 'contact-subtitle', [text('We are here to help with sales, support, and business enquiries.')]),
            div(classes: 'contact-layout', [
              div(classes: 'contact-card', [
                h2([text('Contact Details')]),
                contactRow(
                  'location_on',
                  'Address',
                  '1st floor, Mangala Complex, Opp Roopa Hotel, Balmatta Rd, Hampankatta, Mangalore 575001',
                ),
                contactRow(
                  'call',
                  'Phone',
                  '+91 824-4254699 / +91 88675-04230',
                ),
                contactRow(
                  'mail',
                  'Email',
                  'info@electralapsolutions.com',
                ),
                div(classes: 'contact-actions', [
                  a(href: 'tel:+918244254699', classes: 'btn btn-primary', [text('Call Now')]),
                  a(href: 'mailto:info@electralapsolutions.com', classes: 'btn btn-ghost', [text('Send Email')]),
                ]),
              ]),
              div(classes: 'contact-side-card', [
                h3([text('Business Hours')]),
                p([text('Monday - Saturday')]),
                p(classes: 'strong', [text('10:00 AM - 7:00 PM')]),
                div(classes: 'contact-divider', []),
                h3([text('Need Quick Help?')]),
                p([text('Our team usually responds within 1 business day.')]),
                Link(to: NavPaths.products, classes: 'checkout-btn', children: [
                  text('Explore Products'),
                  span(classes: 'material-symbols-outlined', [text('arrow_forward')]),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]),
      const AppFooter(),
    ]);
  }
}

Component contactRow(String icon, String label, String value) {
  return div(classes: 'contact-row', [
    div(classes: 'contact-row-icon', [
      span(classes: 'material-symbols-outlined', [text(icon)]),
    ]),
    div(classes: 'contact-row-copy', [
      h4([text(label)]),
      p([text(value)]),
    ]),
  ]);
}
