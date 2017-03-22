class InputError extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      message: 'Input is invalid'
    };
  }
  render(){ 
    var errorClass = classNames(this.props.className, {
      'error_container':   true,
      'visible':           this.props.visible,
      'invisible':         !this.props.visible
    });

    return (
      <div className={errorClass}>
        <span>{this.props.errorMessage}</span>
      </div>
    );
  }
}

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
        })
      }
    </select>;
  }
}

class TelegramForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      tlgTerm: '',
      tlgHeader: this.props.tlgHeader,
      stationIndex: '34622',
      group00: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^[134/][1-4][0-9/]([0-4][0-9]|50|5[6-9]|[6-9][0-9]|\/\/)$/ },
      group0: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^[0-9/]([012][0-9]|3[0-6]|99|\/\/)([012][0-9]|30|\/\/)$/ },
      group1: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^1[01][0-5][0-9][0-9]$/ },
      group2: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^2[01][0-5][0-9][0-9]$/ },
      group3: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^3\d{4}$/ },
      group4: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^4\d{4}$/ },
      group5: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^5[0-8]\d{3}$/ },
      group6: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^6\d{3}[12]$/ }, // From Margo 20170315 
      group7: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^7\d{4}$/ },
      group8: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^8[0-9/]{4}$/ }, // From Margo 20170317 
      group31: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^1[01][0-9]{3}$/ },
      group32: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^2[01][0-9]{3}$/ },
      group34: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^4[0-9/][0-9]{3}$/ },
      group35: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^55[0-9]{3}$/ },
      group38: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^8[0-9/]{2}([0-4][0-9]|50|5[6-9]|[6-9][0-9])$/ },
      group39: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^9[0-9]{4}$/ },
      group51: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^1[0-9/][01][0-9]{2}$/ },
      group53: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^3[0-9/][01][0-9]{2}$/ },
      group55: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^52[01][0-9]{2}$/ },
      group56: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^6[0-9/]{4}$/ },
      group59: {value:'', errorVisible: false, errorMessage: 'Ошибка!', regex: /^9[0-9/]{4}$/ },
      tlgText: this.props.tlgHeader,
      errors: this.props.errors
    };

    this.row1 = ['group00', 'group0', 'group1', 'group2', 'group3', 'group4', 'group5', 'group6', 'group7', 'group8'];
    this.row3 = ['group31', 'group32', 'group34', 'group35', 'group38', 'group39'];
    this.row5 = ['group51', 'group53', 'group55', 'group56', 'group59'];
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleTextChange = this.handleTextChange.bind(this);
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.makeText = this.makeText.bind(this);
    this.handleGroup00Change = this.handleGroup00Change.bind(this);
  }
  makeText(){
    let section3 = '';
    let section5 = '';
    let self = this;
    if(this.state.group31.value.length>0 | this.state.group32.value.length>0 | this.state.group34.value.length>0 | this.state.group35.value.length>0 |
      this.state.group38.value.length>0 | this.state.group39.value.length>0){
      section3 = ' 333';
      this.row3.forEach(function(val) {
        section3 += (self.state[val].value.length>0 ? ' '+self.state[val].value : '');
      });
    }
    if(this.state.group51.value.length>0 | this.state.group53.value.length>0 | this.state.group55.value.length>0 | this.state.group56.value.length>0 |
      this.state.group59.value.length>0){
      section5 = ' 555';
      this.row5.forEach(function(val) {
        section5 += (self.state[val].value.length>0 ? ' '+self.state[val].value : '');
      });
    }
    this.setState({tlgText: this.state.tlgHeader+' '+this.state.stationIndex+' '+this.state.group00.value+' '+
      this.state.group0.value+' '+this.state.group1.value+' '+this.state.group2.value+' '+this.state.group3.value+' '+this.state.group4.value+' '+
      this.state.group5.value+' '+this.state.group6.value+' '+this.state.group7.value+' '+this.state.group8.value+section3+section5});
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
    var group = e.target.value;
    var regex = '';
    this.state[e.target.name].value = e.target.value;
    this.makeText();
    if(group.length<5){
      return;
    } 
    regex = this.state[e.target.name].regex;
    if (!regex.test(group)) 
      this.state[e.target.name].errorVisible = true;
    else
      this.state[e.target.name].errorVisible = false;
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
    var tds = [];
    var td333 = [];
    var td555 = [];
    var self = this;
    this.row1.forEach(function(td) {
      tds.push( <td>
                  <input type="text" value={self.state[td].value} onChange={self.handleGroup00Change} name={td} key={td} />
                  <InputError visible={self.state[td].errorVisible} errorMessage={self.state[td].errorMessage} key={'err_'+td} />
                </td>);
    });
    this.row3.forEach(function(td) {
      td333.push(<td>
                   <input type="text" value={self.state[td].value} onChange={self.handleGroup00Change} name={td} key={td} />
                   <InputError visible={self.state[td].errorVisible} errorMessage={self.state[td].errorMessage} key={'err_'+td} />
                 </td>);
    });
    this.row5.forEach(function(td) {
      td555.push(<td>
                   <input type="text" value={self.state[td].value} onChange={self.handleGroup00Change} name={td} key={td} />
                   <InputError visible={self.state[td].errorVisible} errorMessage={self.state[td].errorMessage} key={'err_'+td} />
                 </td>);
    });
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
              <th>Группа2</th>
              <th>Группа3</th>
              <th>Группа4</th>
              <th>Группа5</th>
              <th>Группа6</th>
              <th>Группа7</th>
              <th>Группа8</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                <OptionSelect options={stations} onUserInput={this.handleOptionSelected} name="selectStation" key="selectStation" />
              </td>
              {tds}
            </tr>
          </tbody>
          <thead>
            <tr>
              <th>Раздел 3</th>
              <th>Группа1</th>
              <th>Группа2</th>
              <th>Группа4</th>
              <th>Группа5</th>
              <th>Группа8</th>
              <th>Группа9</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                333
              </td>
              {td333}
            </tr>
          </tbody>
          <thead>
            <tr>
              <th>Раздел 5</th>
              <th>Группа1</th>
              <th>Группа3</th>
              <th>Группа5</th>
              <th>Группа6</th>
              <th>Группа9</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                555
              </td>
              {td555}
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