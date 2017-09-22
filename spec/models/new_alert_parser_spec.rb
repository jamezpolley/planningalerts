require 'spec_helper'

describe NewAlertParser do
  describe "#parse" do
    before :each do
      mock_geocoder_valid_address_response
    end

    context "when there is no matching pre-existing Alert" do
      it "returns the original alert" do
        alert = build(:alert, address: "24 Bruce Rd, Glenbrook")

        parser_result = NewAlertParser.new(alert).parse

        expect(parser_result).to eql alert
      end

      it "geocodes the alert" do
        alert = build(:alert, id: 7, address: "24 Bruce Rd, Glenbrook", lat: nil, lng: nil)

        parser_result = NewAlertParser.new(alert).parse

        expect(parser_result.address).to eq "24 Bruce Rd, Glenbrook, VIC 3885"
        expect(parser_result.geocoded?).to be true
      end
    end

    context "when there is a matching pre-existing unconfirmed Alert" do
      let(:alert_subscriber) { create(:alert_subscriber, email: "jenny@example.com") }

      let!(:preexisting_alert) do
        create(
          :unconfirmed_alert,
          address: "24 Bruce Rd, Glenbrook, VIC 3885",
          alert_subscriber: alert_subscriber,
          created_at: 3.days.ago,
          updated_at: 3.days.ago
        )
      end

      it "resends the confirmation email for the pre-existing alert" do
        allow(ConfirmationMailer).to receive(:confirm).with("default", preexisting_alert).and_call_original
        new_alert = build(
          :alert,
          alert_subscriber: alert_subscriber,
          address: "24 Bruce Rd, Glenbrook",
          lat: nil,
          lng: nil,
          theme: "default"
        )

        NewAlertParser.new(new_alert).parse

        expect(ConfirmationMailer).to have_received(:confirm).with("default", preexisting_alert)
      end

      it "returns nil" do
        new_alert = build(
          :alert,
          alert_subscriber: alert_subscriber,
          address: "24 Bruce Rd, Glenbrook",
          lat: nil,
          lng: nil
        )

        parser_result = NewAlertParser.new(new_alert).parse

        expect(parser_result).to be nil
      end
    end

    context "when there is a matching confirmed alert" do
      let(:alert_subscriber) { create(:alert_subscriber, email: "jenny@example.com") }

      let!(:preexisting_alert) do
        create(
          :confirmed_alert,
          address: "24 Bruce Rd, Glenbrook, VIC 3885",
          alert_subscriber: alert_subscriber,
          created_at: 3.days.ago,
          updated_at: 3.days.ago,
          theme: "default"
        )
      end

      it "returns nil" do
        new_alert = build(
          :alert,
          alert_subscriber: alert_subscriber,
          address: "24 Bruce Rd, Glenbrook",
          lat: nil,
          lng: nil
        )

        parser_result = NewAlertParser.new(new_alert).parse

        expect(parser_result).to be nil
      end

      it "sends a helpful email to the alert’s email address" do
        allow(AlertNotifier).to receive(:new_signup_attempt_notice).with(preexisting_alert).and_call_original
        new_alert = build(
          :alert,
          alert_subscriber: alert_subscriber,
          address: "24 Bruce Rd, Glenbrook",
          lat: nil,
          lng: nil
        )

        NewAlertParser.new(new_alert).parse

        expect(AlertNotifier).to have_received(:new_signup_attempt_notice).with(preexisting_alert)
      end

      context "but it is unsubscribed" do
        before do
          preexisting_alert.unsubscribe!
        end

        it "returns the new alert" do
          new_alert = build(
            :alert,
            id: 9,
            alert_subscriber: alert_subscriber,
            address: "24 Bruce Rd, Glenbrook",
            lat: nil,
            lng: nil
          )

          parser_result = NewAlertParser.new(new_alert).parse

          expect(parser_result.id).to eq 9
        end
      end
    end
  end
end
