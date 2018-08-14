resource "aws_sqs_queue" "artisan_metrics_queue" {
  name                       = "artisan_metrics_queue-${var.environment}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 30
  receive_wait_time_seconds  = 0
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.artisan_metrics_queue_deadletter.arn}\",\"maxReceiveCount\":5}"
}

resource "aws_sqs_queue_policy" "artisan_metrics_queue_policy" {
  queue_url = "${aws_sqs_queue.artisan_metrics_queue.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.artisan_metrics_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sqs_queue.artisan_metrics_queue.arn}"
        }
      }
    }
  ]
}
POLICY
}

output "artisan_metrics_queue_url" {
  value = ${aws_sqs_queue.artisan_metrics_queue.id}
}