class TelegramForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      tlgTerm: '',
      tlgText: this.props.tlgText
    };
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleTermChange = this.handleTermChange.bind(this);
    this.handleTextChange = this.handleTextChange.bind(this);
  }
  handleTermChange(e) {
    this.setState({tlgTerm: e.target.value});
  }
  handleTextChange(e) {
    this.setState({tlgText: e.target.value});
  }
  handleSubmit(e) {
    e.preventDefault();
    var term = this.state.tlgTerm.trim();
    var text = this.state.tlgText.trim();
    if (!term || !text) {
      return;
    }
    this.props.onTelegramSubmit({"Срок": term, "Телеграмма": text});
    this.setState({tlgTerm: '', tlgText: ''});
  }
  render() {
    return (
      <form className="telegramForm" onSubmit={this.handleSubmit}>
        <p>Срок:
        <input
          type="text"
          placeholder="09"
          value={this.state.tlgTerm}
          onChange={this.handleTermChange}
        /></p>
        <p>Текст: 
        <input
          type="text"
          placeholder="Щ..."
          size="100"
          value={this.state.tlgText}
          onChange={this.handleTextChange}
        /></p>
        <input type="submit" value="Сохранить" />
      </form>
    );
  }
}
class TelegramEditForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      tlgText: this.props.tlgText
    };
    this.handleTextChange = this.handleTextChange.bind(this);
    this.handleEditSubmit = this.handleEditSubmit.bind(this);
  }
  handleTextChange(e) {
    this.setState({tlgText: e.target.value});
  }
  handleEditSubmit(e){
    e.preventDefault();
    this.props.onTelegramEditSubmit({tlgText: this.state.tlgText});
  }
  
  render() {
    return (
      <form className="telegramEditForm" onSubmit={this.handleEditSubmit}>
        <input
          type="text"
          size="100"
          value={this.state.tlgText}
          onChange={this.handleTextChange}
        />
        <input type="submit" value="Сохранить" />
      </form>
    );
  }
}
class OneTelegram extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      tlgText: this.props.telegram["Телеграмма"],
      mode: 'Изменить'
    };
    this.handleEditClick = this.handleEditClick.bind(this);
    this.handleEditFormSubmit = this.handleEditFormSubmit.bind(this);
  }
  handleEditClick(e){
    if (this.state.mode == 'Изменить')
      this.setState({mode:'Отменить'});
    else
      this.setState({mode:'Изменить'});
  }
  handleEditFormSubmit(tlgText){
    this.setState({mode: "Изменить", tlgText: tlgText.tlgText});
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: "update_synoptic_telegram?t_date="+this.props.telegram["Дата"]+"&t_text="+tlgText.tlgText
      }).done(function(data) {
        // alert(data["Дата"])
        // newTelegrams[0]["Дата"] = data["Дата"];
        // this.setState({telegrams: newTelegrams});
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      });
  }
  render() {
    var now = Date.now();
    var desiredLink = "/synoptics/show_by_date?Дата="+this.props.telegram["Дата"];
    return (
      <tr>
        <td>{this.props.telegram["Дата"]}</td>
        <td>{this.props.telegram["Срок"]}</td>
        {this.state.mode == 'Изменить' ? <td><a href={desiredLink}>{this.state.tlgText}</a></td> : <td><TelegramEditForm tlgText={this.state.tlgText} onTelegramEditSubmit={this.handleEditFormSubmit}/></td>}
        {(now - Date.parse(this.props.telegram["Дата"].replace(/\./g , "-"))) > 1000 * 60 * 60 * 24 * 7 ? <td></td> : <td><input id={this.props.telegram["Дата"]} type="submit" value={this.state.mode} onClick={this.handleEditClick}/></td>}
      </tr>
    );
  }
}
class TelegramsTable extends React.Component{
  render() {
    var rows = [];
    this.props.telegrams.forEach(function(t) {
      rows.push(<OneTelegram telegram={t} key={t["Дата"]} />);
    });
    return (
      <table className="table table-hover">
        <thead>
          <tr>
            <th>Дата</th>
            <th>Срок</th>
            <th>Текст</th>
            <th>Действия</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}

class Telegrams extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      telegrams: this.props.telegrams
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  handleFormSubmit(telegram) {
    // telegram.date = new Date;
    var telegrams = this.state.telegrams;
    var newTelegrams = [telegram].concat(telegrams);
    this.setState({telegrams: newTelegrams});
    $.ajax({
      type: 'POST',
      dataType: 'json',
      url: "create_synoptic_telegram?t_term="+telegram["Срок"]+"&t_text="+telegram["Телеграмма"]
      }).done(function(data) {
        // alert(data["Дата"])
        newTelegrams[0]["Дата"] = data["Дата"];
        this.setState({telegrams: newTelegrams});
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      }); 
  }
  
  render(){
    return(
      <div>
        <h3>Создать новую телеграмму</h3>
        <TelegramForm onTelegramSubmit={this.handleFormSubmit} tlgText = {''}/>
        <h3>Телеграммы</h3>
        <TelegramsTable telegrams={this.state.telegrams} />
      </div>
    );
  }
}