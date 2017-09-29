class SearchParamsForm extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      dateFrom: this.props.dateFrom,
      dateTo: this.props.dateTo,
      term: '99',
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
      this.state.term = value;
  }
  handleTextChange(e) {
    this.setState({text: e.target.value});
  }

  handleSubmit(e) {
    e.preventDefault();
    this.props.onTelegramSubmit({dateFrom: this.state.dateFrom, dateTo: this.state.dateTo, stationCode: this.state.stationCode, term: this.state.term, text: this.state.text});
  }

  render() {
    const terms = [
      { value: '99', label: 'Любой' },
      { value: '00', label: '00' },
      { value: '03', label: '03' },
      { value: '06', label: '06' },
      { value: '09', label: '09' },
      { value: '12', label: '12' },
      { value: '15', label: '15' },
      { value: '18', label: '18' },
      { value: '21', label: '21' }
    ];
    // var self = this;
    return (
      <form className="telegramForm" onSubmit={this.handleSubmit}>
        <table className="table table-hover">
          <thead>
            <tr>
              <th>Дата с</th>
              <th>Дата по</th>
              <th>Срок</th>
              <th>Метеостанция</th>
              <th>Текст</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><input type="date" name="input-date-from" value={this.state.dateFrom} onChange={this.dateFromChange} required="true" autoComplete="on" /></td>
              <td><input type="date" name="input-date-to" value={this.state.dateTo} onChange={this.dateToChange} required="true" autoComplete="on" /></td>
              <td><OptionSelect options={terms} onUserInput={this.handleOptionSelected} name = "selectTerms" defaultValue="99"/></td>
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
class FoundTelegram extends React.Component{
  constructor(props) {
    super(props);
    // this.state = {
    //   tlgText: this.props.telegram.telegram,
    //   tlgId: this.props.telegram.id,
    //   mode: 'Изменить'
    // };
    // this.handleEditClick = this.handleEditClick.bind(this);
    // this.handleEditTelegramSubmit = this.handleEditTelegramSubmit.bind(this);
  }
  render() {
    var desiredLink = "/synoptic_observations/"+this.props.telegram.id;
    return (
      <tr>
        <td>{this.props.telegram.date}</td>
        <td>{this.props.telegram.term}</td>
        <td>{this.props.telegram.station_name}</td>
        <td><a href={desiredLink}>{this.props.telegram.telegram}</a></td>
      </tr>
    );
  }
}

class FoundTelegrams extends React.Component{
  render() {
    var rows = [];
    // var that = this;
    this.props.telegrams.forEach(function(t) {
      rows.push(<FoundTelegram telegram={t} key={t.id}/>);
    });
    return (
      <table className="table table-hover">
        <thead>
          <tr>
            <th>Дата</th>
            <th>Срок</th>
            <th>Метеостанция</th>
            <th>Текст</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}

class SearchSynopticTelegrams extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
    //   date: this.props.date,
      telegrams: this.props.telegrams,
      klass: 'visible',
      errors: {}
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
    this.handleChangeClick = this.handleChangeClick.bind(this);
  }
  handleChangeClick(e){
    if (this.state.klass == 'visible') {
      this.setState({klass:'invisible'});
    } else
      this.setState({klass:'visible'});
  }

  handleFormSubmit(params) {
    var that = this;
    // alert(params.date)
    var term = params.term == '99' ? '' : "&term="+params.term;
    var stationCode = params.stationCode == '0' ? '' : "&station_code="+params.stationCode;
    var text = params.text.length > 1 ? "&text="+params.text : '';
    $.ajax({
      type: 'GET',
      dataType: 'json',
      // data: {observation: telegram.observation},
      url: "search_synoptic_telegrams?date_from="+params.dateFrom+"&date_to="+params.dateTo+term+stationCode+text
      }).done(function(data) {
        that.setState({telegrams: data.telegrams, errors: {}});
      }.bind(that))
      .fail(function(res) {
        that.setState({errors: ["Ошибка записи в базу"]});
      }.bind(that)); 
  }
  
  render(){
    // var errorClass = classNames(this.props.className, {
    //   'error_container':   true,
    //   'visible':           this.props.visible,
    //   'invisible':         !this.props.visible
    // });
    return (
      <div>
        {/*<input type="submit" value="Сменить" onClick={this.handleChangeClick}/>
        <div className={this.state.klass}>    
        </div> */}
        <h3>Параметры поиска</h3>
        <SearchParamsForm onTelegramSubmit={this.handleFormSubmit} dateFrom={this.props.dateFrom} dateTo={this.props.dateTo} errors={this.state.errors} stations={this.props.stations} tlgText={this.state.tlgText}/>
        <h3>Найденные телеграммы ({this.state.telegrams.length})</h3>
        <FoundTelegrams telegrams={this.state.telegrams}/>
      </div>
    );
  }
}