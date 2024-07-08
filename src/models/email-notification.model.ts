export class EmailNotification {
  public sender: DataEmail = new DataEmail();
  public to: DataEmail[] = [];
  public subject: string = '';
  public htmlContent: string = '';

  constructor(sender: DataEmail, to: DataEmail[], subject: string, htmlContent: string) {
    this.sender = sender;
    this.to = to;
    this.subject = subject;
    this.htmlContent = htmlContent;
  }
}

export class DataEmail {
  name: string = '';
  email: string = '';
}
