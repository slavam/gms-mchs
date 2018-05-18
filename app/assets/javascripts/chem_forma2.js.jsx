class ChemOptionSelect extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      defaultValue: this.props.defaultValue
    };
    this.handleOptionChange = this.handleOptionChange.bind(this);
  }
  handleOptionChange(event) {
    this.props.onUserInput(event.target.value, event.target.name);
  }
  render(){
    return <select name={this.props.name} onChange={this.handleOptionChange} defaultValue = {this.state.defaultValue}>
      {
        this.props.options.map(function(op) {
          return <option key={op.id} value={op.id}>{op.name}</option>;
        })
      }
    </select>;
  }
}

class Forma2Params extends React.Component{
  constructor(props) {
    super(props);
    // var placeId = this.props.regionType == 'post' ? 5 : 1;
    this.state = {
      postId: this.props.placeId,
      dateFrom: this.props.dateFrom,
      dateTo: this.props.dateTo
    };
    this.handleOptionSelected = this.handleOptionSelected.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.dateFromChange = this.dateFromChange.bind(this);
    this.dateToChange = this.dateToChange.bind(this);
  }
  handleSubmit(e) {
    e.preventDefault();
    var postId = this.state.postId;
    var dateFrom = this.state.dateFrom;
    var dateTo = this.state.dateTo;
    if (!dateFrom || !dateTo || !postId) {
      return;
    }
    this.props.onParamsSubmit({dateFrom: dateFrom, dateTo: dateTo, placeId: postId});
  }
  handleOptionSelected(value, senderName){
    if (senderName == 'selectPost'){
      this.state.postId = value;
    }
  }
  dateFromChange(e) {
    this.setState({dateFrom: e.target.value});
  }
  dateToChange(e) {
    this.setState({dateTo: e.target.value});
  }
  render() {
    var defaultId = this.props.regionType == 'post' ? 5 : 1;
    return (
      <form className="paramsForm" onSubmit={this.handleSubmit}>
        <table className= "table table-hover">
          <thead>
            <tr>
              <th>Место</th>
              <th>Начальная дата</th>
              <th>Конечная дата</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>
                <ChemOptionSelect options={this.props.posts} onUserInput={this.handleOptionSelected} name="selectPost" key="selectPost" defaultValue = {defaultId}/>
              </td>
              <td>
                <input type="date" name="dateFrom" value={this.state.dateFrom} onChange={this.dateFromChange} />
              </td>
              <td>
                <input type="date" name="dateTo" value={this.state.dateTo} onChange={this.dateToChange} />
              </td>
            </tr>
          </tbody>
        </table>
        <input type="submit" value="Пересчитать" />
      </form>
    );
  }
}
class Forma2OneRow extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      pollution: this.props.pollution
    };
  }
  render() {
    var p = this.props.data;
    var k =  this.props.material_id;
    return (
      <tr key={k}><td>{k}</td><td>{p.material_name}</td><td>{p.size}</td><td>{p.mean}</td>
         <td>{p.max_concentration.value}</td><td>{p.max_concentration.post_id}</td><td>{p.max_concentration.date}</td><td>{p.max_concentration.term}</td>
         <td>{p.standard_deviation}</td><td>{p.variance}</td><td>{p.percent1}</td><td>{p.percent5}</td><td>{p.percent10}</td>
         <td>{p.lt_1pdk}</td><td>{p.lt_5pdk}</td><td>{p.lt_10pdk}</td><td>{p.pollution_index}</td>
         <td>{p.avg_conc}</td><td>{p.max_conc}</td>
      </tr>
    );
  }
}
class Forma2Table extends React.Component {
  render() {
    var rows = [];
    Object.keys(this.props.pollutions).forEach((k) => rows.push(<Forma2OneRow data={this.props.pollutions[k]} material_id={k} key={k}/>));
    return (
      <table className="table table-hover">
        <thead>
          <tr>
            <th>Код</th>
            <th>Название</th>
            <th>Число замеров</th>
            <th>Средняя конц.</th>
            <th>Макс. конц.</th>
            <th>Пост</th>
            <th>Дата</th>
            <th>Срок</th>
            <th>Среднекв. отклонение</th>
            <th>Коэффициент вариации</th>
            <th>Процент повторяемости</th>
            <th>Процент повторяемости 5ПДК</th>
            <th>Процент повторяемости 10ПДК</th>
            <th>Количество превышений</th>
            <th>Количество превышений 5ПДК</th>
            <th>Количество превышений 10ПДК</th>
            <th>ИЗА</th>
            <th>Средняя концентрация в ПДКср</th>
            <th>Максимальная концентрация в ПДКмакс</th>
          </tr>
        </thead>
        <tbody>
          {rows}
        </tbody>
      </table>
    );
  }
}
class ChemForma2 extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      dateFrom: this.props.dateFrom,
      dateTo: this.props.dateTo,
      regionType: this.props.regionType,
      scopeName: this.props.scopeName,
      pollutions: this.props.pollutions
    };
    this.desiredLink = "/measurements/print_forma2.pdf?date_from="+this.props.dateFrom+"&date_to="+this.props.dateTo+"&place_id="+this.props.placeId+"&region_type="+this.props.regionType;
    this.handleParamsSubmit = this.handleParamsSubmit.bind(this);
  }
  
  handleParamsSubmit(params) {
    this.desiredLink = "/measurements/print_forma2.pdf?date_from="+params.dateFrom+"&date_to="+params.dateTo+"&place_id="+params.placeId+"&region_type="+this.props.regionType;
    $.ajax({
      type: 'GET',
      url: "get_chem_forma2_data?date_from="+params.dateFrom+"&date_to="+params.dateTo+"&place_id="+params.placeId+"&region_type="+this.props.regionType
      }).done(function(data) {
        this.setState({
          pollutions: data.pollutions,
          scopeName: data.scopeName,
          dateFrom: data.dateFrom,
          dateTo: data.dateTo
        });
      }.bind(this))
      .fail(function(jqXhr) {
        console.log('failed to register');
      });
  }
  render(){
    return(
      <div>
        <h4>Период с {this.state.dateFrom} по {this.state.dateTo} {this.state.scopeName}</h4>
        <h3>Задайте параметры расчета</h3>
        <Forma2Params onParamsSubmit={this.handleParamsSubmit} dateFrom={this.state.dateFrom} dateTo={this.state.dateTo} posts={this.props.posts} regionType={this.props.regionType} placeId={this.props.placeId}/>
        <Forma2Table pollutions={this.state.pollutions} />
        <br />
        <a href={this.desiredLink}>Распечатать</a>
      </div>
    );
  }
}