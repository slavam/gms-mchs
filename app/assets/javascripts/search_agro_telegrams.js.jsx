class AgroSearchForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      dateFrom: this.props.dateFrom,
      dateTo: this.props.dateTo,
      stationCode: '0',
      text: '',
      errors: this.props.errors,
    };
    this.dateFromChange = this.dateFromChange.bind(this);
    this.dateToChange = this.dateToChange.bind(this);
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleTextChange = this.handleTextChange.bind(this);
  }
  dateFromChange(e){
    this.setState({dateFrom: e.target.value});
  }
  dateToChange(e){
    this.setState({dateTo: e.target.value});
  }
  handleOptionSelected(value, senderName){
    if (senderName == 'selectStation')
      this.state.stationCode = value;
    else
      this.state.type = value;
  }
  handleTextChange(e) {
    this.setState({text: e.target.value});
  }

  handleSubmit(e) {
    e.preventDefault();
    this.props.onFormSubmit({dateFrom: this.state.dateFrom, dateTo: this.state.dateTo, stationCode: this.state.stationCode, text: this.state.text, type: this.state.type});
  }

  render() {
    return (
      <form className="telegramForm" onSubmit={this.handleSubmit}>
        <table className="table table-hover">
          <thead>
            <tr>
              <th>Дата с</th>
              <th>Дата по</th>
              <th>Метеостанция</th>
              <th>Текст</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><input type="date" name="input-date-from" value={this.state.dateFrom} onChange={this.dateFromChange} required="true" autoComplete="on" /></td>
              <td><input type="date" name="input-date-to" value={this.state.dateTo} onChange={this.dateToChange} required="true" autoComplete="on" /></td>
              <td><TlgOptionSelect options={this.props.stations} onUserInput={this.handleOptionSelected} name="selectStation" key="selectStation" defaultValue="0" /></td>
              <td><input type="text" value={this.state.text} onChange={this.handleTextChange}/></td>
            </tr>
          </tbody>
        </table>
        <p>
          <span style={{color: 'red'}}>{this.state.errors[0]}</span>
        </p>
        <input type="submit" value="Искать" />
      </form>
    );
  }        
}

class FoundAgroTelegram extends React.Component{
  constructor(props) {
    super(props);
  }
  render() {
    var desiredLink = "/agro_observations/"+this.props.telegram.id;
    return (
      <tr>
        <td>{this.props.telegram.date.substr(0, 19)+' UTC'}</td>
        <td>{this.props.telegram.station_name}</td>
        <td><a href={desiredLink}>{this.props.telegram.telegram}</a></td>
      </tr>
    );
  }
}

class FoundAgroTelegrams extends React.Component{
  render() {
    var rows = [];
    this.props.telegrams.forEach((t) => {
      t.date = t.date.replace(/T/,' ');
      rows.push(<FoundAgroTelegram telegram={t} key={t.id}/>);
    });
    return (
      <table className="table table-hover">
        <thead>
          <tr>
            <th width="200px">Дата</th>
            <th>Метеостанция</th>
            <th>Текст</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}

class SearchAgroTelegrams extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      telegrams: this.props.telegrams,
      errors: []
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  handleFormSubmit(params) {
    var that = this;
    var stationCode = params.stationCode == '0' ? '' : "&station_code="+params.stationCode;
    var text = params.text.length > 1 ? "&text="+params.text : '';
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: "search_agro_telegrams?date_from="+params.dateFrom+"&date_to="+params.dateTo+stationCode+text
      }).done(function(data) {
        that.setState({telegrams: data.telegrams, errors: []});
      }.bind(that))
      .fail(function(res) {
        that.setState({errors: ["Ошибка поиска"]});
      }.bind(that)); 
  }
  
  render(){
    return (
      <div>
        <h3>Параметры поиска</h3>
        <AgroSearchForm onFormSubmit={this.handleFormSubmit} dateFrom={this.props.dateFrom} dateTo={this.props.dateTo} errors={this.state.errors} stations={this.props.stations}/>
        <h3>Найденные телеграммы ({this.state.telegrams.length})</h3>
        <FoundAgroTelegrams telegrams={this.state.telegrams}/>
      </div>
    );
  }
}