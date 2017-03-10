
class OptionSelect extends React.Component{
  constructor(props) {
    super(props);
    this.handleOptionChange = this.handleOptionChange.bind(this);
  }
  handleOptionChange(event) {
    this.props.onUserInput(event.target.value, event.target.name);
  }
  render(){
    
    return <select name = {this.props.name} onChange = {this.handleOptionChange}>
      {
        this.props.options.map(function(op) {
          return <option key = {op.value} value = {op.value}> {op.label} </option>;
        }
      )}
    </select>;
  }
}

class TelegramForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      tlgTerm: '',
      tlgHeader: this.props.tlgHeader,
      stationIndex: '',
      group00: '',
      tlgText: this.props.tlgHeader,
      errors: this.props.errors
    };
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleTextChange = this.handleTextChange.bind(this);
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.makeText = this.makeText.bind(this);
    this.handleGroup00Change = this.handleGroup00Change.bind(this);
  }
  makeText(){
    this.setState({tlgText: this.state.tlgHeader+' '+this.state.stationIndex+' '+this.state.group00});
  }
  handleOptionSelected(value, senderName){
    if (senderName == 'selectStation'){
      this.state.stationIndex = value;
    }else{
      this.state.tlgTerm = value;
      this.state.tlgHeader = (+value % 2 == 0) ? "ЩЭСМЮ" : "ЩЭСИД";
    }
    this.makeText();
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
    this.setState({ tlgText: '', errors: this.props.errors});
  }
  handleGroup00Change(e){
    let gr00 = e.target.value;
    let iRvalues = ['1', '3', '4', '/'];
    let iXvalues = ['1', '2', '3', '4'];
    if(iRvalues.indexOf(gr00[0])==-1)
      alert("Недопустимое значение iR");
    else if(gr00.length>1 && iXvalues.indexOf(gr00[1])==-1)
      alert("Недопустимое значение iX");
    else {
      this.state.group00 = e.target.value;
      this.makeText();
    }
  }
  render() {
    const stations = [
      { value: '34622', label: 'Амвросиевка' },
      { value: '34524', label: 'Дебальцево' },
      { value: '34519', label: 'Донецк' },
      { value: '34615', label: 'Волноваха' },
      { value: '34712', label: 'Мариуполь' },
      { value: '34523', label: 'Луганск' },
      { value: '34510', label: 'Артемовск' },
      { value: '34514', label: 'Красноармейск' }
    ];
    const terms = [
      { value: '00', label: '00' },
      { value: '03', label: '03' },
      { value: '06', label: '06' },
      { value: '09', label: '09' },
      { value: '12', label: '12' },
      { value: '15', label: '15' },
      { value: '18', label: '18' },
      { value: '21', label: '21' }
    ];
    return (
      <form className="telegramForm" onSubmit={this.handleSubmit}>
        <p>Срок:
          <OptionSelect options={terms} onUserInput={this.handleOptionSelected} name = "selectTerms"/>
          <span style={{color: 'red'}}>{this.props.errors.terms}</span>
        </p>
        <table className="table table-hover">
          <thead>
            <tr>
              <th>Метеостанция</th>
              <th>Группа00</th>
              <th>Группа0</th>
              <th>Группа1</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                <OptionSelect options={stations} onUserInput={this.handleOptionSelected} name="selectStation" />
              </td>
              <td>
                <input type="text" size="10" value={this.state.group00} onChange={this.handleGroup00Change} />
              </td>
              <td>
              </td>
              <td>
              </td>
            </tr>
          </tbody>
        </table>
        
        <p>Текст: 
        <input
          type="text"
          placeholder="Щ..."
          size="100"
          value={this.state.tlgText}
          onChange={this.handleTextChange}
        />
        <span style={{color: 'red'}}>{this.props.errors.group0}</span>
        </p>
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
      telegrams: this.props.telegrams,
      errors: {}
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  handleFormSubmit(telegram) {
    var that = this;
    var telegrams = that.state.telegrams;
    var newTelegrams = [telegram].concat(telegrams);
    that.setState({telegrams: newTelegrams});
    $.ajax({
      type: 'POST',
      dataType: 'json',
      url: "create_synoptic_telegram?t_term="+telegram["Срок"]+"&t_text="+telegram["Телеграмма"]
      }).done(function(data) {
        // alert(data["Дата"])
        newTelegrams[0]["Дата"] = data["Дата"];
        that.setState({telegrams: newTelegrams, errors: {}});
      }.bind(that))
      .fail(function(res) {
        that.setState({errors: res.responseJSON.errors});
      }.bind(that)); 
  }
  
  render(){
    return(
      <div>
        <h3>Создать новую телеграмму</h3>
        <TelegramForm onTelegramSubmit={this.handleFormSubmit} tlgHeader = {'ЩЭСМЮ'} errors = {this.state.errors} />
        <h3>Телеграммы</h3>
        <TelegramsTable telegrams={this.state.telegrams} />
      </div>
    );
  }
}