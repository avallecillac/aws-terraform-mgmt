resource "aws_sns_topic" "artisan-metrics" {
  name: "artisan-metrics-sns-${var.environment}"
}

resource "aws_sns_topic_policy" "default" {
  arn = "${aws_sns_topic.artisan-metrics.arn}"

  policy = "${data.aws_iam_policy_document.sns-topic-policy.json}"
}

resource "aws_sns_topic_subscription" "artisan-metrics-queue-target" {
  topic_arn = "${aws_sns_topic.artisan-metrics.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.artisan_metrics_queue.arn}"
}

data "aws_iam_policy_document" "sns-topic-policy" {
  policy_id = "artisan-metrics-policy-id"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:Publish"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        "${var.account-id}",
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_sns_topic.artisan-metrics.arn}",
    ]

    sid = "__default_statement_ID"
  }

  output "aws_sns_topic_arn" {
    value = ${aws_sns_topic.artisan-metrics.arn}
  }